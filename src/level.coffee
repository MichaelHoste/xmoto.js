class Level

  constructor: ->
    @assets = new Assets()

    @infos         = new Infos(this)
    @sky           = new Sky(this)
    @blocks        = new Blocks(this)
    @limits        = new Limits(this)
    @layer_offsets = new LayerOffsets(this)
    @script        = new Script(this)
    @entities      = new Entities(this)

  load_from_file: (file_name) ->
    $.ajax({
      type:     "GET",
      url:      "data/Levels/#{file_name}",
      dataType: "xml",
      success:  @load_level
      async:    false
      context:  @
    })

  load_level: (xml) ->
    @infos        .parse(xml).load_assets()
    @sky          .parse(xml).load_assets()
    @blocks       .parse(xml).load_assets()
    @limits       .parse(xml).load_assets()
    @layer_offsets.parse(xml).load_assets()
    @script       .parse(xml).load_assets()
    @entities     .parse(xml).load_assets()

  load_assets: (callback) ->
    @assets.load_for_level(this, callback)

  draw: ->
    canvas  = $('#game').get(0)
    canvas_width  = parseFloat(canvas.width)
    canvas_height = canvas.width * (@limits.size.y / @limits.size.x)
    $('#game').attr('height', canvas_height)

    @ctx = canvas.getContext('2d')

    @scale =
      x:   canvas_width  / @limits.size.x
      y: - canvas_height / @limits.size.y

    translate =
      x: - @limits.screen.left
      y: - @limits.screen.top

    @ctx.scale(@scale.x, @scale.y)
    @ctx.translate(translate.x, translate.y)
    @ctx.lineWidth = 0.1

    @sky     .display(@ctx)
    @limits  .display(@ctx)
    @blocks  .display(@ctx)
    @entities.display(@ctx)

  triangulate: ->
    @triangles = []
    for block in @blocks.list
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
  level = new Level()
  level.load_from_file('l1038.lvl') # l9562.lvl  # l1287.lvl (snake) # l1038
  level.load_assets( ->
    level.triangulate()
    level.draw()

    physics = new Physics(30)
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
    setInterval(update, 1000 / 60)
  )

