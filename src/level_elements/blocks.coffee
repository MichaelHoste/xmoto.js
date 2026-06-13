class Blocks

  constructor: (level) ->
    @level  = level
    @assets = level.assets

    @list = []

  parse: (xml) ->
    xml_blocks = $(xml).find('block')

    for xml_block in xml_blocks
      block =
        id: $(xml_block).attr('id')
        position:
          x:          parseFloat($(xml_block).find('position').attr('x'))
          y:          parseFloat($(xml_block).find('position').attr('y'))
          dynamic:    $(xml_block).find('position').attr('dynamic')    == 'true'
          background: $(xml_block).find('position').attr('background') == 'true'
          islayer:    $(xml_block).find('position').attr('islayer') == 'true'
          layerid:    do ->
                        attr = $(xml_block).find('position').attr('layerid')
                        if attr? then parseInt(attr) else undefined # integer or undefined if no attribute
        usetexture:
          id:         $(xml_block).find('usetexture').attr('id').toLowerCase()
          scale:      parseFloat($(xml_block).find('usetexture').attr('scale')) || 1.0
        physics:
          grip:       parseFloat($(xml_block).find('physics').attr('grip'))
        edges:
          angle:      parseFloat($(xml_block).find('edges').attr('angle'))
          materials:  []
        vertices:     []

      block.no_collision  =  block.position.background                                     # background                   => no collision (old syntax)
      block.no_collision ||= block.position.islayer && block.position.layerid != undefined # layer with specific layerid  => no collision

      block.usetexture.id = 'dirt' if block.usetexture.id == 'default'

      texture_params = @assets.theme.texture_params(block.usetexture.id)

      if texture_params.frames > 0
        block.animated     = true
        block.frames_count = texture_params.frames
        block.delay        = texture_params.delay
        block.frame_names  = (@frame_name(texture_params, i) for i in [0..texture_params.frames - 1])
        block.texture_name = block.frame_names[0]
      else
        block.animated     = false
        block.texture_name = texture_params.file

      xml_materials = $(xml_block).find('edges material')
      for xml_material in xml_materials
        material =
          name:    $(xml_material).attr('name')
          edge:    $(xml_material).attr('edge')
          color_r: parseInt($(xml_material).attr('color_r'))
          color_g: parseInt($(xml_material).attr('color_g'))
          color_b: parseInt($(xml_material).attr('color_b'))
          color_a: parseInt($(xml_material).attr('color_a'))
          scale:   parseFloat($(xml_material).attr('scale'))
          depth:   parseFloat($(xml_material).attr('depth'))

        block.edges.materials.push(material)

      xml_vertices = $(xml_block).find('vertex')
      for xml_vertex in xml_vertices
        vertex =
          x:          parseFloat($(xml_vertex).attr('x'))
          y:          parseFloat($(xml_vertex).attr('y'))
          absolute_x: parseFloat($(xml_vertex).attr('x')) + block.position.x # absolutes positions are practical
          absolute_y: parseFloat($(xml_vertex).attr('y')) + block.position.y # for edges creation
          edge:       $(xml_vertex).attr('edge').toLowerCase() if $(xml_vertex).attr('edge')

        block.vertices.push(vertex)

      block.edges_list = new Edges(@level, block)
      #block.edges_list = new EdgesWithAngle(@level, block)
      block.edges_list.parse()

      block.aabb = @compute_aabb(block)

      @list.push(block)

    @list.sort(@sort_blocks_by_texture)

    return this

  load_assets: ->
    for block in @list
      if block.animated
        @assets.textures.push(frame_name) for frame_name in block.frame_names
      else
        @assets.textures.push(block.texture_name)

      block.edges_list.load_assets()

  init: ->
    @init_physics()
    @init_sprites()
    @init_culling_debug()

    for block in @list
      block.edges_list.init()

  init_physics: ->
    ground = Constants.ground

    for block in @list
      if !block.no_collision
        @level.physics.create_lines(block, 'ground', ground.density, ground.restitution, ground.friction)

  init_sprites: ->
    for block in @list
      # Build polygon in world PIXI coordinates (y inverted)
      block.points = block.vertices.map((v) ->
        new PIXI.Point(v.absolute_x, -v.absolute_y)
      )

      # Not translating the matrix ensures texture continuity between blocks
      block.matrix = new PIXI.Matrix()
      block.matrix.scale(block.usetexture.scale / 60.0, -block.usetexture.scale / 60.0)
      #block.matrix.translate(block.aabb.lowerBound.x, -block.aabb.upperBound.y)

      if block.animated
        block.frame_textures = (PIXI.Texture.from(@assets.get_url(name)) for name in block.frame_names)
        block.current_frame  = 0
        # Stagger the animation start so neighbouring blocks of the same texture
        # don't tear: they all share the same wall-clock based frame index.
        block.animation_start = performance.now()
      else
        block.texture = PIXI.Texture.from(@assets.get_url(block.texture_name))

      # Create graphics with texture and matrix
      block.graphics = new PIXI.Graphics()
      block.graphics.label = block.id

      @draw_block_fill(block, if block.animated then block.frame_textures[0] else block.texture)

      @level.layers.layer_for_block(block).addChild(block.graphics)

  draw_block_fill: (block, texture) ->
    block.graphics.clear()
    block.graphics.poly(block.points)
    block.graphics.fill({
      texture:      texture,
      matrix:       block.matrix,
      color:        0xffffff,
      alpha:        1.0,
      textureSpace: 'global'
    })

  # One Graphic is created in each block layer (parallax or static)
  # for drawing culling rectangles. It's because parallax layers
  # have their own scale/translate reference
  init_culling_debug: ->
    if Constants.debug_culling
      @culling_debug_graphics = {} # { label => graphics }

      for block in @list
        layer = @level.layers.layer_for_block(block)

        if !@culling_debug_graphics[layer.label]
          graphics          = new PIXI.Graphics()
          graphics.label    = "culling (blocks - #{layer.label})"
          graphics.parallax = layer.parallax # needed for later
          layer.addChild(graphics)

          @culling_debug_graphics[layer.label] = graphics

  update: ->
    if !Constants.debug_physics
      now = performance.now()

      for block in @list
        block.graphics.visible = @visible(block)
        block.edges_list.update()

        if block.animated && block.graphics.visible
          @update_animation(block, now)

    if Constants.debug_culling
      @draw_debug_culling()

  update_animation: (block, now) ->
    elapsed = (now - block.animation_start) / 1000.0
    frame   = Math.floor(elapsed / block.delay) % block.frames_count

    if frame != block.current_frame
      block.current_frame = frame
      @draw_block_fill(block, block.frame_textures[frame])

  draw_debug_culling: ->
    culling_debugs = Object.values(@culling_debug_graphics)

    for culling_debug in culling_debugs
      culling_debug.clear()

    for block in @list
      if block.aabb && block.graphics.visible
        layer         = @level.layers.layer_for_block(block)
        culling_debug = @culling_debug_graphics[layer.label]
        culling_debug.rect(
          block.aabb.lowerBound.x,
          -block.aabb.upperBound.y,
          block.aabb.upperBound.x - block.aabb.lowerBound.x,
          block.aabb.upperBound.y - block.aabb.lowerBound.y
        )

    # Parallax layers use a fixed 1px stroke (pixelLine) to stay readable
    for calling_debug in Object.values(@culling_debug_graphics)
      if calling_debug.parallax
        calling_debug.stroke(color: 0xC7C778, alpha: 0.7, pixelLine: true)
      else
        line_width = 0.04 * Constants.default_scale.x / @level.camera.scale.x
        calling_debug.stroke(width: line_width, color: 0xC7C778, alpha: 0.7)

  visible: (block) ->
    if block.position.islayer && block.position.layerid != undefined
      parallax_layer = @level.layers.list[block.position.layerid]
      block.aabb.TestOverlap(parallax_layer.camera_aabb)
    else
      block.aabb.TestOverlap(@level.camera.aabb)

  compute_aabb: (block) ->
    x_positions = block.vertices.map((v) -> v.absolute_x)
    y_positions = block.vertices.map((v) -> v.absolute_y)

    aabb = new Box2D.Collision.b2AABB()
    aabb.lowerBound.Set(Math.min.apply(null, x_positions), Math.min.apply(null, y_positions))
    aabb.upperBound.Set(Math.max.apply(null, x_positions), Math.max.apply(null, y_positions))

    return aabb

  frame_name: (texture_params, frame_number) ->
    "#{texture_params.file_base}#{(frame_number/100.0).toFixed(2).toString().substring(2)}.#{texture_params.file_extension}"

  # Blocks drawing is sorted by textures:
  # http://wiki.xmoto.tuxfamily.org/index.php?title=Others_tips_to_make_levels#Parallax_layers
  sort_blocks_by_texture: (a, b) ->
    return 1  if a.usetexture.id > b.usetexture.id
    return -1 if a.usetexture.id <= b.usetexture.id
    return 0
