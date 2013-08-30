class Level

  constructor: ->
    # Context
    canvas  = $('#game').get(0)
    @ctx = canvas.getContext('2d')

    # Assets manager
    @assets        = new Assets()

    # Box2D World
    @physics       = new Physics(this)
    @world         = @physics.world

    # Moto (level independant)
    @moto          = new Moto(this)

    # Level dependent objects
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
    @infos        .parse(xml).init()
    @sky          .parse(xml).init()
    @blocks       .parse(xml).init()
    @limits       .parse(xml).init()
    @layer_offsets.parse(xml).init()
    @script       .parse(xml).init()
    @entities     .parse(xml).init()

  display: ->
    canvas  = $('#game').get(0)
    canvas_width  = parseFloat(canvas.width)
    canvas_height = canvas.width * (@limits.size.y / @limits.size.x)
    $('#game').attr('height', canvas_height)

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
