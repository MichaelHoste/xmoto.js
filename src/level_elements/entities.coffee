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
          width:  do ->
                    attr = $(xml_entity).find('size').attr('width')
                    if attr? then parseFloat(attr) else undefined # integer or undefined if no attribute (will come from theme)
          height: do ->
                    attr = $(xml_entity).find('size').attr('height')
                    if attr? then parseFloat(attr) else undefined # integer or undefined if no attribute (will come from theme)
        position:
          x:        parseFloat($(xml_entity).find('position').attr('x'))
          y:        parseFloat($(xml_entity).find('position').attr('y'))
          angle:    parseFloat($(xml_entity).find('position').attr('angle')) || 0
          reversed: $(xml_entity).find('position').attr('reversed') == 'true'
        center:
          x: undefined # can only come from theme
          y: undefined # can only come from theme
        params: {}

      # parse params tags
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
        theme_sprite = @assets.theme.sprite_params(texture_name)

        if theme_sprite
          entity.file           = theme_sprite.file
          entity.file_base      = theme_sprite.file_base
          entity.file_extension = theme_sprite.file_extension
          entity.delay          = theme_sprite.delay
          entity.frames_count   = theme_sprite.frames_count
          entity.display        = true # if an entity has a texture, it needs to be displayed

          # Default theme values if not defined in XML
          theme_width    = theme_sprite.size.width  || 1.0
          theme_height   = theme_sprite.size.height || 1.0
          theme_center_x = theme_sprite.center.x    || 0.5
          theme_center_y = theme_sprite.center.y    || 0.5

          # - When the level overrides width/height, we keep the sprite centered on the
          #   sprite's original centerX/centerY by shifting the center by half the size delta.
          # - If level doesn't overrides width/height, we simply use theme values
          if entity.size.width
            entity.center.x = theme_center_x + (entity.size.width - theme_width)  / 2
          else
            entity.size.width = theme_width
            entity.center.x   = theme_center_x

          if entity.size.height
            entity.center.y = theme_center_y + (entity.size.height - theme_height) / 2
          else
            entity.size.height = theme_height
            entity.center.y    = theme_center_y

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
        if entity.frames_count == 0
          @assets.anims.push(entity.file)
        else
          for i in [0..entity.frames_count-1]
            @assets.anims.push(@frame_name(entity, i))

  init: ->
    @init_physics()
    @init_graphics()
    @init_culling_debug()

  init_physics: ->
    for entity in @list
      # End of level
      if entity.typeid == 'EndOfLevel'
        @create_entity_physics(entity, 'end_of_level')
        @end_of_level = entity

      # Strawberries
      else if entity.typeid == 'Strawberry'
        @create_entity_physics(entity, 'strawberry')
        @strawberries.push(entity)

      # Wreckers
      else if entity.typeid == 'Wrecker'
        @create_entity_physics(entity, 'wrecker')
        @wreckers.push(entity)

      # Player start
      else if entity.typeid == 'PlayerStart'
        @player_start =
          x: entity.position.x
          y: entity.position.y

  create_entity_physics: (entity, name) ->
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

  init_graphics: ->
    for entity in @list
      if entity.z == 0
        @init_sprite(entity, @level.layers.static_level)
      else if entity.z < 0
        @init_sprite(entity, @level.layers.static_background)
      else if entity.z > 0
        @init_sprite(entity, @level.layers.static_foreground)

  init_sprite: (entity, container) ->
    if entity.frames_count
      textures = []
      for i in [0..entity.frames_count - 1]
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

      entity.graphics = sprite # keep reference to the sprite
      container.addChild(sprite)

  init_culling_debug: ->
    if Constants.debug_culling
      @culling_debug = new PIXI.Graphics()
      @culling_debug.label = 'culling (entities)'
      @level.layers.translate_layer.addChild(@culling_debug)

  update: (entity) ->
    if !Constants.debug_physics
      for entity in @list
        if entity.graphics
          entity.graphics.visible = @visible(entity)

    if Constants.debug_culling
      @draw_debug_culling()

  draw_debug_culling: ->
    @culling_debug.clear()

    for entity in @list
      if entity.aabb && entity.graphics.visible
        @culling_debug.rect(
          entity.aabb.lowerBound.x,
          -entity.aabb.upperBound.y,
          entity.aabb.upperBound.x - entity.aabb.lowerBound.x,
          entity.aabb.upperBound.y - entity.aabb.lowerBound.y
        )

    line_width = 0.04 * Constants.default_scale.x / @level.camera.scale.x

    @culling_debug.stroke(width: line_width, color: 0x78C7C7, alpha: 0.7)

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
    # limits relative to anchor
    left   = -entity.center.x
    right  = left + entity.size.width
    bottom = -entity.center.y
    top    = bottom + entity.size.height

    corners = [
      { x: left,  y: bottom }
      { x: right, y: bottom }
      { x: right, y: top    }
      { x: left,  y: top    }
    ]

    # We always rotate the 4 corners by the entity.position.angle (usually 0!)
    # with entity.position as anchor
    xs = []
    ys = []
    for corner in corners
      rotated = Math2D.rotate_point(corner, entity.position.angle, entity.position)
      xs.push(rotated.x)
      ys.push(rotated.y)

    aabb = new Box2D.Collision.b2AABB()
    aabb.lowerBound.Set(Math.min(xs...), Math.min(ys...))
    aabb.upperBound.Set(Math.max(xs...), Math.max(ys...))

    return aabb

  visible: (entity) ->
    entity.display && entity.aabb.TestOverlap(@level.camera.aabb)

  frame_name: (entity, frame_number) ->
    "#{entity.file_base}#{(frame_number/100.0).toFixed(2).toString().substring(2)}.#{entity.file_extension}"
