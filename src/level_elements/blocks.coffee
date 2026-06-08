class Blocks

  constructor: (level) ->
    @level  = level
    @assets = level.assets

    @list       = [] # total list
    @back_list  = [] # background list
    @front_list = [] # front list (collisions)

  parse: (xml) ->
    xml_blocks = $(xml).find('block')

    for xml_block in xml_blocks
      block =
        id: $(xml_block).attr('id')
        position:
          x:          parseFloat($(xml_block).find('position').attr('x'))
          y:          parseFloat($(xml_block).find('position').attr('y'))
          dynamic:    $(xml_block).find('position').attr('dynamic')    == 'true'
          background: $(xml_block).find('position').attr('background') == 'true'   # collisions and layer=0 but at the back
          islayer:    $(xml_block).find('position').attr('islayer') == 'true'      # if true, then no collisions
          layerid:    parseInt($(xml_block).find('position').attr('layerid')) || 0
        usetexture:
          id:         $(xml_block).find('usetexture').attr('id').toLowerCase()
          scale:      parseFloat($(xml_block).find('usetexture').attr('scale'))
        physics:
          grip:       parseFloat($(xml_block).find('physics').attr('grip'))
        edges:
          angle:      parseFloat($(xml_block).find('edges').attr('angle'))
          materials:  []
        vertices:     []

      block.usetexture.id = 'dirt' if block.usetexture.id == 'default'
      block.texture_name = @assets.theme.texture_params(block.usetexture.id).file

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
          absolute_x: parseFloat($(xml_vertex).attr('x')) + block.position.x # absolutes positions are here to
          absolute_y: parseFloat($(xml_vertex).attr('y')) + block.position.y # accelerate drawing of each frame
          edge:       $(xml_vertex).attr('edge').toLowerCase() if $(xml_vertex).attr('edge')

        block.vertices.push(vertex)

      block.edges_list = new Edges(@level, block)
      #block.edges_list = new EdgesWithAngle(@level, block)
      block.edges_list.parse()

      block.aabb = @compute_aabb(block)

      @list.push(block)

      is_background =   block.position.background                            # old syntax
      is_background ||= block.position.islayer && block.position.layerid > 0 # new syntax

      if is_background
        @back_list.push(block)
      else
        @front_list.push(block)

    @list      .sort(@sort_blocks_by_texture)
    @back_list .sort(@sort_blocks_by_texture)
    @front_list.sort(@sort_blocks_by_texture)

    return this

  load_assets: ->
    for block in @list
      @assets.textures.push(block.texture_name)
      block.edges_list.load_assets()

  init: ->
    @init_physics_parts()
    @init_sprites()

    for block in @list
      block.edges_list.init()

  init_physics_parts: ->
    ground = Constants.ground

    for block in @front_list
      @level.physics.create_lines(block, 'ground', ground.density, ground.restitution, ground.friction)

  init_sprites: ->
    # draw back blocks before front blocks
    for block in @back_list.concat(@front_list)
      # Build polygon in world PIXI coordinates (y inverted)
      points = block.vertices.map((v) ->
        new PIXI.Point(v.absolute_x, -v.absolute_y)
      )

      # Load block texture
      texture = PIXI.Texture.from(@assets.get_url(block.texture_name))

      # Matrix maps world coords
      matrix = new PIXI.Matrix()
      matrix.scale(1.0 / 50.0, 1.0 / 50.0)
      matrix.translate(block.aabb.lowerBound.x, -block.aabb.upperBound.y)

      # Create graphics with texture and matrix
      block.graphics = new PIXI.Graphics()
      block.graphics.poly(points)
      block.graphics.fill({
        texture:      texture,
        matrix:       matrix,
        color:        0xffffff,
        alpha:        1.0,
        textureSpace: 'global'
      })

      @level.camera.neutral_z_container.addChild(block.graphics)

  update: ->
    if !Constants.debug_physics
      for block in @list
        block.graphics.visible = @visible(block)
        block.edges_list.update()

  visible: (block) ->
    block.aabb.TestOverlap(@level.camera.aabb)

  compute_aabb: (block) ->
    x_positions = block.vertices.map((v) -> v.absolute_x)
    y_positions = block.vertices.map((v) -> v.absolute_y)

    aabb = new Box2D.Collision.b2AABB()
    aabb.lowerBound.Set(Math.min.apply(null, x_positions), Math.min.apply(null, y_positions))
    aabb.upperBound.Set(Math.max.apply(null, x_positions), Math.max.apply(null, y_positions))

    return aabb

  # http://wiki.xmoto.tuxfamily.org/index.php?title=Others_tips_to_make_levels#Parallax_layers
  sort_blocks_by_texture: (a, b) ->
    return 1  if a.usetexture.id > b.usetexture.id
    return -1 if a.usetexture.id <= b.usetexture.id
    return 0
