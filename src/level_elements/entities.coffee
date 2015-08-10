b2FixtureDef = Box2D.Dynamics.b2FixtureDef

class Entities

  constructor: (level) ->
    @level        = level
    @assets       = level.assets
    @world        = level.physics.world
    @list         = []
    @strawberries = []
    @wreckers     = []

  parse: (xml) ->
    xml_entities = $(xml).find('entity')

    # parse entity xml
    for xml_entity in xml_entities
      entity =
        id:      $(xml_entity).attr('id')
        type_id: $(xml_entity).attr('typeid')
        size:
          r:      parseFloat($(xml_entity).find('size').attr('r'))
          width:  parseFloat($(xml_entity).find('size').attr('width'))
          height: parseFloat($(xml_entity).find('size').attr('height'))
        position:
          x:     parseFloat($(xml_entity).find('position').attr('x'))
          y:     parseFloat($(xml_entity).find('position').attr('y'))
          angle: parseFloat($(xml_entity).find('position').attr('angle')) || 0
        params: []

      # parse params xml
      xml_params = $(xml_entity).find('param')
      for xml_param in xml_params
        param =
          name:  $(xml_param).attr('name')
          value: $(xml_param).attr('value')
        entity.params.push(param)

      # Get default values for sprite from theme
      texture_name = @entity_texture_name(entity)
      if texture_name
        sprite = @assets.theme.sprite_params(texture_name)

        entity.file        = sprite.file
        entity.file_base   = sprite.file_base
        entity.file_ext    = sprite.file_ext
        entity.size.width  = sprite.size.width  if not entity.size.width
        entity.size.height = sprite.size.height if not entity.size.height
        entity.center =
          x: sprite.center.x
          y: sprite.center.y
        entity.center.x = entity.size.width/2  if not entity.center.x
        entity.center.y = entity.size.height/2 if not entity.center.y

        # no size informations into the theme or into the level
        entity.size.width  = 2*entity.size.r   if not entity.size.width
        entity.size.height = 2*entity.size.r   if not entity.size.height
        entity.center.x    = entity.size.r     if not entity.center.x
        entity.center.y    = entity.size.r     if not entity.center.y

        entity.delay    = sprite.delay
        entity.frames   = sprite.frames
        entity.display  = true # if an entity has a texture, it needs to be displayed

        entity.aabb = entity_AABB(entity)

      @list.push(entity)

    return this

  load_assets: ->
    for entity in @list
      if entity.display
        if entity.frames == 0
          @assets.anims.push(entity.file)
        else
          for i in [0..entity.frames-1]
            @assets.anims.push(frame_name(entity, i))

  init_physics_parts: ->
    for entity in @list
      # End of level
      if entity.type_id == 'EndOfLevel'
        @create_entity(entity, 'end_of_level')
        @end_of_level = entity

      # Strawberries
      else if entity.type_id == 'Strawberry'
        @create_entity(entity, 'strawberry')
        @strawberries.push(entity)

      else if entity.type_id == 'Wrecker'
        @create_entity(entity, 'wrecker')
        @wreckers.push(entity)

      # Player start
      else if entity.type_id == 'PlayerStart'
        @player_start =
          x: entity.position.x
          y: entity.position.y

  init_sprites: ->
    for entity in @list
      if entity.type_id == 'Sprite'
        @init_entity(entity)

  init_items: ->
    for entity in @list
      if entity.type_id == 'EndOfLevel' or entity.type_id == 'Strawberry' or entity.type_id == 'Wrecker'
        @init_entity(entity)

  init_entity: (entity) ->
    if entity.frames > 0
      textures = []
      for i in [0..entity.frames - 1]
        textures.push(PIXI.Texture.fromImage(@assets.get_url(frame_name(entity, i))))

      entity.sprite = new PIXI.extras.MovieClip(textures)
      entity.sprite.animationSpeed = 0.5 - 0.5 * entity.delay
      entity.sprite.play()
      @level.camera.container2.addChild(entity.sprite)
    else
      if entity.file
        entity.sprite = new PIXI.Sprite.fromImage(@assets.get_url(entity.file))
        @level.camera.container2.addChild(entity.sprite)

  create_entity: (entity, name) ->
    # Create fixture
    fixDef = new b2FixtureDef()
    fixDef.shape = new b2CircleShape(entity.size.r)
    fixDef.isSensor = true

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = entity.position.x
    bodyDef.position.y = entity.position.y

    bodyDef.userData =
      name:   name
      entity: entity

    bodyDef.type = b2Body.b2_staticBody

    # Assign fixture to body and add body to 2D world
    body = @world.CreateBody(bodyDef)
    body.CreateFixture(fixDef)

    body

  display: (entity) ->
    return false if Constants.debug

    for entity in @list
      if visible_entity(entity) && (entity.file || entity.frames > 0)
        entity.sprite.width    = entity.size.width
        entity.sprite.height   = entity.size.height
        entity.sprite.anchor.x = entity.center.x / entity.size.width
        entity.sprite.anchor.y = 1 - (entity.center.y / entity.size.height)
        entity.sprite.x        =  entity.position.x
        entity.sprite.y        = -entity.position.y
        entity.sprite.rotation = -entity.position.angle
      else
        if entity.sprite
          entity.sprite.x = -10000

  entity_texture_name: (entity) ->
    if entity.type_id == 'Sprite'
      for param in entity.params
        if param.name == 'name'
          return param.value
    else if entity.type_id == 'EndOfLevel'
      return 'Flower'
    else if entity.type_id == 'Strawberry' or entity.type_id == 'Wrecker'
      return entity.type_id

frame_name = (entity, frame_number) ->
  "#{entity.file_base}#{(frame_number/100.0).toFixed(2).toString().substring(2)}.#{entity.file_ext}"

entity_AABB = (entity) ->
  lower_bound = {}
  upper_bound = {}
  lower_bound.x = entity.position.x - entity.size.width + entity.center.x
  lower_bound.y = entity.position.y - entity.center.y
  upper_bound.x = lower_bound.x + entity.size.width
  upper_bound.y = lower_bound.y + entity.size.height

  aabb = new b2AABB()
  aabb.lowerBound.Set(lower_bound.x, lower_bound.y)
  aabb.upperBound.Set(upper_bound.x, upper_bound.y)

  return aabb

visible_entity = (entity) ->
  entity.display
