b2Vec2 = Box2D.Common.Math.b2Vec2
b2AABB = Box2D.Collision.b2AABB

class Blocks

  constructor: (level) ->
    @level      = level
    @assets     = level.assets
    @theme      = @assets.theme
    @list       = [] # total list
    @back_list  = [] # background list
    @front_list = [] # front list (collisions)

    @edges = new Edges(@level)

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
      block.texture_name = @theme.texture_params(block.usetexture.id).file

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
          x:    parseFloat($(xml_vertex).attr('x'))
          y:    parseFloat($(xml_vertex).attr('y'))
          absolute_x: parseFloat($(xml_vertex).attr('x')) + block.position.x # absolutes positions are here to
          absolute_y: parseFloat($(xml_vertex).attr('y')) + block.position.y # accelerate drawing of each frame
          edge: $(xml_vertex).attr('edge').toLowerCase() if $(xml_vertex).attr('edge')

        block.vertices.push(vertex)

      block.aabb = block_AABB(block)

      @list.push(block)
      if block.position.background
        @back_list.push(block)
      else
        @front_list.push(block)

    @list      .sort( sort_blocks_by_texture )
    @back_list .sort( sort_blocks_by_texture )
    @front_list.sort( sort_blocks_by_texture )

    @edges.parse(@list)

    return this

  load_assets: ->
    for block in @list
      @assets.textures.push(block.texture_name)

    @edges.load_assets()

  init: ->
    @init_physics_parts()
    @init_sprites()

  init_physics_parts: ->
    ground = Constants.ground
    for block in @front_list
      @level.physics.create_lines(block, 'ground', ground.density, ground.restitution, ground.friction)

  init_sprites: ->
    # draw back blocks before front blocks
    for block in @back_list.concat(@front_list)
      # Create mask
      points = []

      for vertex, i in block.vertices
        points.push(new PIXI.Point(vertex.x, -vertex.y))

      mask = new PIXI.Graphics()
      mask.beginFill(0x8bc5ff, 0.4)
      mask.drawPolygon(points)
      mask.x =  block.position.x
      mask.y = -block.position.y
      @level.camera.container2.addChild(mask)

      # Create tilingSprite
      texture = PIXI.Texture.fromImage(@assets.get_url(block.texture_name))
      size_x  = block.aabb.upperBound.x - block.aabb.lowerBound.x
      size_y  = block.aabb.upperBound.y - block.aabb.lowerBound.y

      @sprite = new PIXI.extras.TilingSprite(texture, size_x, size_y)
      @sprite.x =  block.position.x
      @sprite.y = -block.position.y
      @sprite.anchor.x   =     Math.abs(block.aabb.lowerBound.x) / size_x
      @sprite.anchor.y   = 1 - Math.abs(block.aabb.lowerBound.y) / size_y
      @sprite.tileScale.x = 1.0/40
      @sprite.tileScale.y = 1.0/40
      @sprite.mask = mask

      @level.camera.container2.addChild(@sprite)

  display: (ctx) ->
    return false if Constants.debug

    # draw back blocks before front blocks
    for block in @back_list.concat(@front_list)
      if visible_block(@level.buffer.visible, block)
        ctx.beginPath()

        for vertex, i in block.vertices
          if i == 0
            ctx.moveTo(vertex.absolute_x, vertex.absolute_y)
          else
            ctx.lineTo(vertex.absolute_x, vertex.absolute_y)

        ctx.closePath()

        ctx.save()
        ctx.scale(1.0 / 40.0, -1.0 / 40.0)
        ctx.fillStyle = ctx.createPattern(@assets.get(block.texture_name), 'repeat')
        ctx.fill()
        ctx.restore()

    @edges.display(ctx)

block_AABB = (block) ->
  first = true
  lower_bound = {}
  upper_bound = {}
  for vertex in block.vertices
    if first
      lower_bound =
        x: vertex.x
        y: vertex.y
      upper_bound =
        x: vertex.x
        y: vertex.y
      first = false
    else
      lower_bound.x = vertex.x if vertex.x < lower_bound.x
      lower_bound.y = vertex.y if vertex.y < lower_bound.y
      upper_bound.x = vertex.x if vertex.x > upper_bound.x
      upper_bound.y = vertex.y if vertex.y > upper_bound.y

  aabb = new b2AABB()
  aabb.lowerBound.Set(lower_bound.x, lower_bound.y)
  aabb.upperBound.Set(upper_bound.x, upper_bound.y)
  return aabb

visible_block = (zone, block) ->
  block.aabb.TestOverlap(zone.aabb)

# http://wiki.xmoto.tuxfamily.org/index.php?title=Others_tips_to_make_levels#Parallax_layers
sort_blocks_by_texture = (a, b) ->
  return 1  if a.usetexture.id > b.usetexture.id
  return -1 if a.usetexture.id <= b.usetexture.id
  return 0
