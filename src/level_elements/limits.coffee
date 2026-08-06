AABB = planck.AABB

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

    texture        = @level.infos.border || 'dirt'
    texture_params = @assets.theme.texture_params(texture)

    if !texture_params
      console.error("XMoto warning: border texture \"#{texture}\" was not found in the theme, falling back to dirt.")
      texture        = 'dirt'
      texture_params = @assets.theme.texture_params(texture)

    if texture_params.frames_count
      @frames_count  = texture_params.frames_count
      @delay         = texture_params.delay
      @texture_names = @texture_names(texture_params)
    else
      @texture_names = [texture_params.file]

    return this

  load_assets: ->
    @assets.textures.push(texture_name) for texture_name in @texture_names

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
      @level.physics.create_polygons_collisions(vertices, 'ground', ground.density, ground.restitution, ground.friction)

  init_graphics: ->
    @textures = (PIXI.Texture.from(@assets.get_url(name)) for name in @texture_names)
    texture.source.addressMode = 'repeat' for texture in @textures

    if @frames_count
      @current_frame   = 0
      @animation_start = performance.now()

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
      uv_scale  = 64.0 / @textures[0].source.width # Same world-space UV formula as Blocks so the texture stays continuous

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
        texture:  @textures[0]
      })

      wall.graphic.label = "limit (#{wall.name})"

      @level.layers.static_level.addChild(wall.graphic)

  init_culling_debug: ->
    if Constants.debug_culling
      @culling_debug = new PIXI.Graphics()
      @culling_debug.label = 'culling (limits)'
      @level.layers.translate_layer.addChild(@culling_debug)

  update: ->
    now = performance.now()

    if !Constants.debug_physics
      for wall in @walls
        wall.graphic.visible = @visible(wall)
        @update_animation(wall, now)

    if Constants.debug_culling
      @draw_debug_culling()

  update_animation: (wall, now) ->
    if wall.graphic.visible && @frames_count
      elapsed = (now - @animation_start) / 1000.0
      frame   = Math.floor(elapsed / @delay) % @frames_count

      if frame != @current_frame
        @current_frame       = frame
        wall.graphic.texture = @textures[frame]

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
    AABB.testOverlap(wall.aabb, @level.camera.aabb)

  compute_aabb: (wall) ->
    aabb = new AABB()
    aabb.lowerBound.set(wall.left,  wall.bottom)
    aabb.upperBound.set(wall.right, wall.top)

    return aabb

  texture_names: (texture_params) ->
    for frame_i in [0..texture_params.frames_count - 1]
      "#{texture_params.file_base}#{(frame_i/100.0).toFixed(2).toString().substring(2)}.#{texture_params.file_extension}"
