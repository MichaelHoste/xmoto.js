class Limits

  constructor: (level) ->
    @level  = level
    @assets = level.assets

  parse: (xml) ->
    xml_limits = $(xml).find('limits')

    # CAREFUL ! The limits on files are not real, some polygons could be outside
    # => It seems to be the limits where the player can go

    @player =
      left:   parseFloat(xml_limits.attr('left'))
      right:  parseFloat(xml_limits.attr('right'))
      top:    parseFloat(xml_limits.attr('top'))
      bottom: parseFloat(xml_limits.attr('bottom'))

    @screen =
      left:   @player.left   - 20
      right:  @player.right  + 20
      top:    @player.top    + 20
      bottom: @player.bottom - 20

    @size =
      x: @screen.right - @screen.left
      y: @screen.top   - @screen.bottom

    # Each wall is a rectangle (in Y-up world coords) — its AABB, physics polygon,
    # and Mesh are all derived from these four bounds.
    @walls = [
      { name: 'left',   left: @screen.left,  right: @player.left,   bottom: @screen.bottom, top: @screen.top    }
      { name: 'right',  left: @player.right, right: @screen.right,  bottom: @screen.bottom, top: @screen.top    }
      { name: 'bottom', left: @player.left,  right: @player.right,  bottom: @screen.bottom, top: @player.bottom }
      { name: 'top',    left: @player.left,  right: @player.right,  bottom: @player.top,    top: @screen.top    }
    ]

    # Compute AABB
    for wall in @walls
      wall.aabb = @compute_aabb(wall)

    @texture      = @level.infos.border || 'dirt'
    @texture_name = @assets.theme.texture_params(@texture).file

    return this

  load_assets: ->
    @assets.textures.push(@texture_name)

  init: ->
    @init_physics()
    @init_graphics()
    @init_culling_debug()

  init_physics: ->
    ground = Constants.ground

    for wall in @walls
      vertices = [
        { x: wall.left,  y: wall.top    }
        { x: wall.left,  y: wall.bottom }
        { x: wall.right, y: wall.bottom }
        { x: wall.right, y: wall.top    }
      ]
      @level.physics.create_polygon(vertices, 'ground', ground.density, ground.restitution, ground.friction)

  init_graphics: ->
    texture = PIXI.Texture.from(@assets.get_url(@texture_name))
    texture.source.addressMode = 'repeat'

    for wall in @walls
      # Four corners in PIXI coords (y inverted): TL, TR, BR, BL.
      corners = [
        { x: wall.left,  y: -wall.top    }
        { x: wall.right, y: -wall.top    }
        { x: wall.right, y: -wall.bottom }
        { x: wall.left,  y: -wall.bottom }
      ]

      positions = new Float32Array(8)
      uvs       = new Float32Array(8)
      uv_scale  = 64.0 / texture.source.width # Same world-space UV formula as Blocks so the texture stays continuous

      for corner, i in corners
        positions[i * 2]     = corner.x
        positions[i * 2 + 1] = corner.y
        uvs[i * 2]           =  uv_scale * corner.x
        uvs[i * 2 + 1]       = -uv_scale * corner.y

      geometry = new PIXI.MeshGeometry({
        positions: positions
        uvs:       uvs
        indices:   new Uint32Array([0, 1, 2, 0, 2, 3])
      })

      wall.graphic = new PIXI.Mesh({
        geometry: geometry
        texture:  texture
      })

      wall.graphic.label = "limit (#{wall.name})"

      @level.layers.static_level.addChild(wall.graphic)

  init_culling_debug: ->
    if Constants.debug_culling
      @culling_debug = new PIXI.Graphics()
      @culling_debug.label = 'culling (limits)'
      @level.layers.translate_layer.addChild(@culling_debug)

  update: ->
    if !Constants.debug_physics
      for wall in @walls
        wall.graphic.visible = @visible(wall)

    if Constants.debug_culling
      @draw_debug_culling()

  draw_debug_culling: ->
    @culling_debug.clear()

    for wall in @walls
      if wall.graphic.visible
        @culling_debug.rect(
          wall.aabb.lowerBound.x,
          -wall.aabb.upperBound.y,
          wall.aabb.upperBound.x - wall.aabb.lowerBound.x,
          wall.aabb.upperBound.y - wall.aabb.lowerBound.y
        )

    line_width = 0.04 * Constants.default_scale.x / @level.camera.scale.x

    @culling_debug.stroke(width: line_width, color: 0xC778C7, alpha: 0.7)

  visible: (wall) ->
    wall.aabb.TestOverlap(@level.camera.aabb)

  compute_aabb: (wall) ->
    aabb = new Box2D.Collision.b2AABB()
    aabb.lowerBound.Set(wall.left,  wall.bottom)
    aabb.upperBound.Set(wall.right, wall.top)

    return aabb
