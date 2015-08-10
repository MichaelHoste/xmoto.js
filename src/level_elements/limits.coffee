b2Vec2 = Box2D.Common.Math.b2Vec2
b2AABB = Box2D.Collision.b2AABB

class Limits

  constructor: (level) ->
    @level  = level
    @assets = level.assets
    @theme  = @assets.theme

  parse: (xml) ->
    xml_limits = $(xml).find('limits')

    # CAREFUL ! The limits on files are not real, some polygons could
    # be in the limits (maybe it's the limits where the player can go)

    @player =
      left:   parseFloat(xml_limits.attr('left'))
      right:  parseFloat(xml_limits.attr('right'))
      top:    parseFloat(xml_limits.attr('top'))
      bottom: parseFloat(xml_limits.attr('bottom'))

    @screen =
      left:   parseFloat(xml_limits.attr('left'))   - 20
      right:  parseFloat(xml_limits.attr('right'))  + 20
      top:    parseFloat(xml_limits.attr('top'))    + 20
      bottom: parseFloat(xml_limits.attr('bottom')) - 20

    @size =
      x: @screen.right - @screen.left
      y: @screen.top   - @screen.bottom

    @texture = 'dirt'
    @texture_name = @theme.texture_params('dirt').file

    return this

  load_assets: ->
    @assets.textures.push(@texture_name)

  init: ->
    @init_physics_parts()
    @init_sprites()

  init_physics_parts: ->
    ground = Constants.ground

    # Left
    vertices = []
    vertices.push({ x: @screen.left, y: @screen.top })
    vertices.push({ x: @screen.left, y: @screen.bottom })
    vertices.push({ x: @player.left, y: @screen.bottom })
    vertices.push({ x: @player.left, y: @screen.top })
    @level.physics.create_polygon(vertices, 'ground', ground.density, ground.restitution, ground.friction)

    # Right
    vertices = []
    vertices.push({ x: @player.right, y: @screen.top })
    vertices.push({ x: @player.right, y: @screen.bottom })
    vertices.push({ x: @screen.right, y: @screen.bottom })
    vertices.push({ x: @screen.right, y: @screen.top })
    @level.physics.create_polygon(vertices, 'ground', ground.density, ground.restitution, ground.friction)

    # Bottom
    vertices = []
    vertices.push({ x: @player.right, y: @player.bottom })
    vertices.push({ x: @player.left,  y: @player.bottom })
    vertices.push({ x: @player.left,  y: @screen.bottom })
    vertices.push({ x: @player.right, y: @screen.bottom })
    @level.physics.create_polygon(vertices, 'ground', ground.density, ground.restitution, ground.friction)

    # Bottom
    vertices = []
    vertices.push({ x: @player.right, y: @screen.top })
    vertices.push({ x: @player.left,  y: @screen.top })
    vertices.push({ x: @player.left,  y: @player.top })
    vertices.push({ x: @player.right, y: @player.top })

    @level.physics.create_polygon(vertices, 'ground', ground.density, ground.restitution, ground.friction)

  init_sprites: ->
    texture = PIXI.Texture.fromImage(@assets.get_url(@texture_name))

    left_size_x = @player.left - @screen.left
    left_size_y = @screen.top  - @screen.bottom

    right_size_x = @screen.right - @player.right
    right_size_y = @screen.top   - @screen.bottom

    bottom_size_x = @player.right  - @player.left
    bottom_size_y = @player.bottom - @screen.bottom

    top_size_x = @player.right - @player.left
    top_size_y = @screen.top   - @player.top

    @left_sprite   = new PIXI.extras.TilingSprite(texture, left_size_x, left_size_y)
    @right_sprite  = new PIXI.extras.TilingSprite(texture, right_size_x, right_size_y)
    @bottom_sprite = new PIXI.extras.TilingSprite(texture, bottom_size_x, bottom_size_y)
    @top_sprite    = new PIXI.extras.TilingSprite(texture, top_size_x, top_size_y)

    @left_sprite.x = @screen.left
    @left_sprite.y = -@screen.top
    @left_sprite.anchor.x   = 0
    @left_sprite.anchor.y   = 0
    @left_sprite.tileScale.x = 1.0/40
    @left_sprite.tileScale.y = 1.0/40

    @right_sprite.x = @player.right
    @right_sprite.y = -@screen.top
    @right_sprite.anchor.x   = 0
    @right_sprite.anchor.y   = 0
    @right_sprite.tileScale.x = 1.0/40
    @right_sprite.tileScale.y = 1.0/40

    @bottom_sprite.x =  @player.left
    @bottom_sprite.y = -@player.bottom
    @bottom_sprite.anchor.x   = 0
    @bottom_sprite.anchor.y   = 0
    @bottom_sprite.tileScale.x = 1.0/40
    @bottom_sprite.tileScale.y = 1.0/40

    @top_sprite.x =  @player.left
    @top_sprite.y = -@screen.top
    @top_sprite.anchor.x   = 0
    @top_sprite.anchor.y   = 0
    @top_sprite.tileScale.x = 1.0/40
    @top_sprite.tileScale.y = 1.0/40

    @level.camera.container2.addChild(@left_sprite)
    @level.camera.container2.addChild(@right_sprite)
    @level.camera.container2.addChild(@bottom_sprite)
    @level.camera.container2.addChild(@top_sprite)


