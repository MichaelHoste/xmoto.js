b2FixtureDef = Box2D.Dynamics.b2FixtureDef

class Entities

  constructor: (level) ->
    @level  = level
    @assets = level.assets
    @list   = []

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
          angle: parseFloat($(xml_entity).find('position').attr('angle'))
        params: []

      # parse params xml
      xml_params = $(xml_entity).find('param')
      for xml_param in xml_params
        param =
          name:  $(xml_param).attr('name')
          value: $(xml_param).attr('value').toLowerCase()
        entity.params.push(param)

      # Get default values for sprite from theme
      if entity.type_id == 'Sprite'
        for param in entity.params
          if param.name == 'name'
            sprite = @assets.theme.sprite_params(param.value)
            entity['center'] =
              x: sprite.center.x if sprite
              y: sprite.center.y if sprite
            entity.size.width  = sprite.size.width  if not entity.size.width
            entity.size.height = sprite.size.height if not entity.size.height

      else if entity.type_id == 'EndOfLevel'
        sprite = @assets.theme.sprite_params('checkball')
        entity.size.width  = sprite.size.width  if not entity.size.width
        entity.size.height = sprite.size.height if not entity.size.height

      @list.push(entity)

    return this

  init: ->
    for entity in @list

      # Sprites (Anims)
      if entity.type_id == 'Sprite'
        for param in entity.params
          if param.name == 'name'
            @assets.anims.push(param.value)

      # End of level
      else if entity.type_id == 'EndOfLevel'
        @assets.anims.push('checkball')
        @end_of_level = @create_end_of_level(entity)

      # Player start
      else if entity.type_id == 'PlayerStart'
        @player_start =
          x: entity.position.x
          y: entity.position.y

  create_end_of_level: (entity) ->
    # Create fixture
    fixDef = new b2FixtureDef()
    fixDef.shape = new b2CircleShape(entity.size.r)
    fixDef.isSensor = true

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = entity.position.x
    bodyDef.position.y = entity.position.y

    bodyDef.userData = 'end_of_level'

    bodyDef.type = b2Body.b2_staticBody

    # Assign fixture to body and add body to 2D world
    body = @level.world.CreateBody(bodyDef)
    body.CreateFixture(fixDef)

    body

  display_sprites: (ctx) ->
    for entity in @list
      if entity.type_id == 'Sprite'
        texture_name = Entities.texture_name(entity)

        ctx.save()
        ctx.translate(entity.position.x, entity.position.y)
        ctx.scale(1, -1)
        ctx.drawImage(@assets.get(texture_name),
                      -entity.size.width  + entity.center.x,
                      -entity.size.height + entity.center.y,
                      entity.size.width,
                      entity.size.height)
        ctx.restore()

  display_items: (ctx) ->
    for entity in @list
      if entity.type_id == 'EndOfLevel'
        texture_name = 'checkball'

        ctx.save()
        ctx.translate(entity.position.x, entity.position.y)
        ctx.scale(1, -1)
        ctx.drawImage(@assets.get(texture_name),
                      -entity.size.width/2,
                      -entity.size.height/2,
                      entity.size.width,
                      entity.size.height)
        ctx.restore()

  @texture_name = (entity) ->
    for param in entity.params
      if param.name == 'name'
        return param.value
