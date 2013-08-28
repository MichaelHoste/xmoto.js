class window.Level

  constructor: ->
    @assets = new window.Assets()

    @infos = new window.Infos()
    @sky   = new window.Sky(this, @assets)

  load_from_file: (file_name) ->
    $.ajax({
      type:     "GET",
      url:      "data/Levels/#{file_name}",
      dataType: "xml",
      success:  @xml_parser
      async:    false
      context:  @
    })

  xml_parser: (xml) ->
    @infos.parse(xml)
    @sky.parse(xml)

    @xml_parse_layer_offsets(xml)
    @xml_parse_limits(xml)
    @xml_parse_script(xml)
    @xml_parse_blocks(xml)
    @xml_parse_entities(xml)

  xml_parse_layer_offsets: (xml) ->
    xml_layer_offsets = $(xml).find('layeroffsets layeroffset')

    @layer_offsets = []

    for xml_layer_offset in xml_layer_offsets
      layer_offset =
        x:           parseFloat($(xml_layer_offset).attr('x'))
        y:           parseFloat($(xml_layer_offset).attr('y'))
        front_layer: $(xml_layer_offset).attr('frontlayer')

      @layer_offsets.push(layer_offset)

  xml_parse_limits: (xml) ->
    xml_limits = $(xml).find('limits')

    # CAREFUL ! The limits on files are not real, some polygons could
    # be in the limits (maybe it's the limits where the player can go)

    @screen_limits =
      left:   parseFloat(xml_limits.attr('left'))   * 1.15
      right:  parseFloat(xml_limits.attr('right'))  * 1.15
      top:    parseFloat(xml_limits.attr('top'))    * 1.15
      bottom: parseFloat(xml_limits.attr('bottom')) * 1.15

    @player_limits =
      left:   parseFloat(xml_limits.attr('left'))
      right:  parseFloat(xml_limits.attr('right'))
      top:    parseFloat(xml_limits.attr('top'))
      bottom: parseFloat(xml_limits.attr('bottom'))

    @size =
      x: @screen_limits.right - @screen_limits.left
      y: @screen_limits.top   - @screen_limits.bottom

  xml_parse_script: (xml) ->
    xml_script = $(xml).find('script')
    @script = xml_script.text()

  xml_parse_blocks: (xml) ->
    xml_blocks = $(xml).find('block')

    @blocks = []

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

      @blocks.push(block)

  xml_parse_entities: (xml) ->
    xml_entities = $(xml).find('entity')

    @entities = []

    for xml_entity in xml_entities
      entity =
        id: $(xml_entity).attr('id')
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

      xml_params = $(xml_entity).find('param')
      for xml_param in xml_params
        param =
          name:  $(xml_param).attr('name')
          value: $(xml_param).attr('value').toLowerCase()
        entity.params.push(param)

      @entities.push(entity)

  load_assets: (callback) ->
    @assets.load_for_level(this, callback)

  draw: ->
    canvas  = $('#game').get(0)
    canvas_width  = parseFloat(canvas.width)
    canvas_height = canvas.width * (@size.y / @size.x)
    $('#game').attr('height', canvas_height)

    @ctx = canvas.getContext('2d')

    scale =
      x:   canvas_width  / @size.x
      y: - canvas_height / @size.y

    translate =
      x: - @screen_limits.left
      y: - @screen_limits.top

    @ctx.scale(scale.x, scale.y)
    @ctx.translate(translate.x, translate.y)
    @ctx.lineWidth = 0.1

    @sky.display(@ctx)

    # Limits
    @ctx.beginPath()
    @ctx.moveTo(@screen_limits.left, @screen_limits.top   )
    @ctx.lineTo(@screen_limits.left, @screen_limits.bottom)
    @ctx.lineTo(@player_limits.left, @screen_limits.bottom)
    @ctx.lineTo(@player_limits.left, @screen_limits.top   )
    @ctx.closePath()

    @ctx.save()
    @ctx.scale(1.0/scale.x, 1.0/scale.y)
    @ctx.fillStyle = @ctx.createPattern(@assets.get('dirt'), "repeat")
    @ctx.fill()
    @ctx.restore()

    @ctx.beginPath()
    @ctx.moveTo(@screen_limits.right, @screen_limits.top   )
    @ctx.lineTo(@screen_limits.right, @screen_limits.bottom)
    @ctx.lineTo(@player_limits.right, @screen_limits.bottom)
    @ctx.lineTo(@player_limits.right, @screen_limits.top   )
    @ctx.closePath()

    @ctx.save()
    @ctx.scale(1.0/scale.x, 1.0/scale.y)
    @ctx.fillStyle = @ctx.createPattern(@assets.get('dirt'), "repeat")
    @ctx.fill()
    @ctx.restore()

    @ctx.beginPath()
    @ctx.moveTo(@player_limits.right, @player_limits.bottom)
    @ctx.lineTo(@player_limits.left,  @player_limits.bottom)
    @ctx.lineTo(@player_limits.left,  @screen_limits.bottom)
    @ctx.lineTo(@player_limits.right, @screen_limits.bottom)
    @ctx.closePath()

    @ctx.save()
    @ctx.scale(1.0/scale.x, 1.0/scale.y)
    @ctx.fillStyle = @ctx.createPattern(@assets.get('dirt'), "repeat")
    @ctx.fill()
    @ctx.restore()

    # Blocks
    for block in @blocks
      @ctx.beginPath()

      for vertex, i in block.vertices
        if i == 0
          @ctx.moveTo(block.position.x + vertex.x, block.position.y + vertex.y)
        else
          @ctx.lineTo(block.position.x + vertex.x, block.position.y + vertex.y)

      @ctx.closePath()

      @ctx.save()
      @ctx.scale(1.0/scale.x, 1.0/scale.y)
      @ctx.fillStyle = @ctx.createPattern(@assets.get(block.usetexture.id), "repeat")
      @ctx.fill()
      @ctx.restore()

    # Sprites
    for entity in @entities
      if entity.type_id == 'Sprite'

        for param in entity.params
          if param.name == 'name'
            image = param.value

        @ctx.save()
        @ctx.translate(entity.position.x, entity.position.y)
        @ctx.scale(1, -1)
        @ctx.drawImage(@assets.get(image), 0, 0, entity.size.r*4, -entity.size.r*4)
        @ctx.restore()

    # End of level
    for entity in @entities
      if entity.type_id == 'EndOfLevel'

        @ctx.save()
        @ctx.translate(entity.position.x - entity.size.r, entity.position.y - entity.size.r)
        @ctx.scale(1, -1)
        @ctx.drawImage(@assets.get('checkball_00'), 0, 0, entity.size.r*2, -entity.size.r*2)
        @ctx.restore()

  triangulate: ->
    @triangles = []
    for block in @blocks
      vertices = []
      for vertex in block.vertices
        vertices.push( new poly2tri.Point(block.position.x + vertex.x, block.position.y + vertex.y ))

      triangulation = new poly2tri.SweepContext(vertices, { cloneArrays: true })
      triangulation.triangulate()
      set_of_triangles = triangulation.getTriangles()

      for triangle in set_of_triangles
        @triangles.push([ { x: triangle.points_[0].x, y: triangle.points_[0].y },
                          { x: triangle.points_[1].x, y: triangle.points_[1].y },
                          { x: triangle.points_[2].x, y: triangle.points_[2].y } ])

$ ->
  level = new window.Level()
  level.load_from_file('l1038.lvl') # l9562.lvl  # l1287.lvl (snake) # l1038
  level.load_assets( ->
    level.triangulate()
    level.draw()

    physics = new window.Physics(30)
    world = physics.createWorld(level.ctx)

    ball   = physics.createBall(world, 1, 7, 1, false, 'ball'+i)
    for triangle in level.triangles
      physics.createTriangle(world, triangle, true, [])

    # Mettre à jour le rendu de l'environnement 2d
    update = ->
      # update physics and canvas
      level.draw()
      world.Step(1 / 60,  10, 10)
      world.DrawDebugData()
      world.ClearForces()

    # Render 2D environment
    window.setInterval(update, 1000 / 60)
  )

