class Blocks

  constructor: (level) ->
    @level  = level
    @assets = level.assets
    @list   = []

  parse: (xml) ->
    xml_blocks = $(xml).find('block')

    @list = []

    for xml_block in xml_blocks
      block =
        id: $(xml_block).attr('id')
        position:
          x:          parseFloat($(xml_block).find('position').attr('x'))
          y:          parseFloat($(xml_block).find('position').attr('y'))
          dynamic:    $(xml_block).find('position').attr('dynamic')
          background: $(xml_block).find('position').attr('background')
        usetexture:
          id:    $(xml_block).find('usetexture').attr('id').toLowerCase()
          scale: parseFloat($(xml_block).find('usetexture').attr('scale'))
        physics:
          grip:  parseFloat($(xml_block).find('physics').attr('grip'))
        edges:
          angle:     parseFloat($(xml_block).find('edges').attr('angle'))
          materials: []
        vertices: []

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
          x:     parseFloat($(xml_vertex).attr('x'))
          y:     parseFloat($(xml_vertex).attr('y'))
          edge : $(xml_vertex).attr('edge')

        block.vertices.push(vertex)

      @list.push(block)

    return this

  init_assets: ->
    for block in @list
      @assets.textures.push(block.usetexture.id)

  display: (ctx) ->
    for block in @list
      ctx.beginPath()

      for vertex, i in block.vertices
        if i == 0
          ctx.moveTo(block.position.x + vertex.x, block.position.y + vertex.y)
        else
          ctx.lineTo(block.position.x + vertex.x, block.position.y + vertex.y)

      ctx.closePath()

      ctx.save()
      ctx.scale(1.0 / @level.scale.x, 1.0 / @level.scale.y)
      ctx.fillStyle = ctx.createPattern(@assets.get(block.usetexture.id), "repeat")
      ctx.fill()
      ctx.restore()

