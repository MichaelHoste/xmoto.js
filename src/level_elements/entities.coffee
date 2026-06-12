class Entities

  constructor: (level) ->
    @level        = level
    @assets       = level.assets
    @world        = level.physics.world
    @list         = []
    @player_start = { x: 0, y: 0 }
    @strawberries = []
    @wreckers     = []

  parse: (xml) ->
    xml_entities = $(xml).find('entity')

    # parse entity xml
    for xml_entity in xml_entities
      entity =
        id:     $(xml_entity).attr('id')
        typeid: $(xml_entity).attr('typeid')
        size:
          r:      parseFloat($(xml_entity).find('size').attr('r'))
          z:      parseInt($(xml_entity).find('size').attr('z')) || undefined
          width:  parseFloat($(xml_entity).find('size').attr('width'))
          height: parseFloat($(xml_entity).find('size').attr('height'))
        position:
          x:        parseFloat($(xml_entity).find('position').attr('x'))
          y:        parseFloat($(xml_entity).find('position').attr('y'))
          angle:    parseFloat($(xml_entity).find('position').attr('angle')) || 0
          reversed: $(xml_entity).find('position').attr('reversed') == 'true'
        params: {}

      # parse params xml
      xml_params = $(xml_entity).find('param')
      for xml_param in xml_params
        name  = $(xml_param).attr('name')
        value = $(xml_param).attr('value')
        entity.params[name] = value

      # find correct z (z can be in <size z="?"> or in <param name="z" value="?">)
      entity['z'] = entity.size.z || parseInt(entity.params.z) || 0

      # Get default values for sprite from theme
      texture_name = @entity_texture_name(entity)
      if texture_name
        sprite = @assets.theme.sprite_params(texture_name)

        if sprite
          entity.file           = sprite.file
          entity.file_base      = sprite.file_base
          entity.file_extension = sprite.file_extension

          # Sprite dimensions from theme (XMoto defaults: width=1, height=1, centerX=0.5, centerY=0.5)
          sprite_width  = if isNaN(sprite.size.width)  then 1.0 else sprite.size.width
          sprite_height = if isNaN(sprite.size.height) then 1.0 else sprite.size.height
          sprite_cx     = if isNaN(sprite.center.x)    then 0.5 else sprite.center.x
          sprite_cy     = if isNaN(sprite.center.y)    then 0.5 else sprite.center.y

          # When the level overrides width/height, XMoto keeps the sprite centered on the
          # sprite's original centerX/centerY by shifting the center by half the size delta.
          # (cf. xmoto Renderer.cpp::_RenderSprite — `v_centerX += (entity.width - sprite.width)/2`)
          level_width  = entity.size.width  > 0
          level_height = entity.size.height > 0
          entity.size.width  = sprite_width  if not level_width
          entity.size.height = sprite_height if not level_height
          entity.center =
            x: sprite_cx + (if level_width  then (entity.size.width  - sprite_width)  / 2 else 0)
            y: sprite_cy + (if level_height then (entity.size.height - sprite_height) / 2 else 0)

          entity.delay   = sprite.delay
          entity.frames  = sprite.frames
          entity.display = true # if an entity has a texture, it needs to be displayed

          entity.aabb = @compute_aabb(entity)
        else
          console.error("XMoto warning: texture file \"#{texture_name}\" was not found in the theme and is ignored.")

      @list.push(entity)

    # order by z-index ASC
    @list.sort((a, b) ->
      return 1  if a.z > b.z
      return -1 if a.z < b.z
      return 0
    )

    return this

  load_assets: ->
    for entity in @list
      if entity.display
        if entity.frames == 0
          @assets.anims.push(entity.file)
        else
          for i in [0..entity.frames-1]
            @assets.anims.push(@frame_name(entity, i))

  init: ->
    @init_physics_parts()
    @init_sprites()

  init_physics_parts: ->
    for entity in @list
      # End of level
      if entity.typeid == 'EndOfLevel'
        @create_entity(entity, 'end_of_level')
        @end_of_level = entity

      # Strawberries
      else if entity.typeid == 'Strawberry'
        @create_entity(entity, 'strawberry')
        @strawberries.push(entity)

      # Wreckers
      else if entity.typeid == 'Wrecker'
        @create_entity(entity, 'wrecker')
        @wreckers.push(entity)

      # Player start
      else if entity.typeid == 'PlayerStart'
        @player_start =
          x: entity.position.x
          y: entity.position.y

  init_sprites: ->
    for entity in @list
      if entity.z == 0
        @init_sprite(entity, @level.layers.static_level)
      else if entity.z < 0
        @init_sprite(entity, @level.layers.static_background)
      else if entity.z > 0
        @init_sprite(entity, @level.layers.static_foreground)

  init_sprite: (entity, container) ->
    if entity.frames > 0
      textures = []
      for i in [0..entity.frames - 1]
        textures.push(PIXI.Texture.from(@assets.get_url(@frame_name(entity, i))))

      sprite = new PIXI.AnimatedSprite(textures)
      sprite.animationSpeed = (1.0 / entity.delay) / Constants.fps
      sprite.play()
    else if entity.file
      sprite = PIXI.Sprite.from(@assets.get_url(entity.file))

    if sprite
      sprite.width    = entity.size.width
      sprite.height   = entity.size.height
      sprite.anchor.x = entity.center.x / entity.size.width
      sprite.anchor.y = 1 - (entity.center.y / entity.size.height)
      sprite.x        =  entity.position.x
      sprite.y        = -entity.position.y
      sprite.rotation = -entity.position.angle
      sprite.name     = entity.params.name || entity.typeid
      sprite.scale.x *= -1 if entity.position.reversed

      entity.sprite = sprite # keep reference to the sprite
      container.addChild(sprite)

  create_entity: (entity, name) ->
    # Create fixture
    fixDef = new Box2D.Dynamics.b2FixtureDef()
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

  update: (entity) ->
    if !Constants.debug_physics
      for entity in @list
        if entity.sprite
          entity.sprite.visible = @visible(entity)

  entity_texture_name: (entity) ->
    if entity.typeid == 'Sprite'
      name = entity.params.name
    else if entity.typeid == 'EndOfLevel' # hard-coded entity
      name = 'Flower'
    else if entity.typeid in ['Strawberry', 'Wrecker'] # hard-coded entities
      name = entity.typeid

    # theme_replacements in XML
    if @level.replacements.sprites[name]
      name = @level.replacements.sprites[name]

    name

  compute_aabb: (entity) ->
    # Mirrors XMoto Renderer.cpp::_RenderSprite — the sprite occupies
    # [pos.x - centerX, pos.x - centerX + width] × [pos.y - centerY, pos.y - centerY + height]
    lower_bound =
      x: entity.position.x - entity.center.x
      y: entity.position.y - entity.center.y

    upper_bound =
      x: lower_bound.x + entity.size.width
      y: lower_bound.y + entity.size.height

    aabb = new Box2D.Collision.b2AABB()
    aabb.lowerBound.Set(lower_bound.x, lower_bound.y)
    aabb.upperBound.Set(upper_bound.x, upper_bound.y)

    return aabb

  visible: (entity) ->
    entity.display && entity.aabb.TestOverlap(@level.camera.aabb)

  frame_name: (entity, frame_number) ->
    "#{entity.file_base}#{(frame_number/100.0).toFixed(2).toString().substring(2)}.#{entity.file_extension}"
