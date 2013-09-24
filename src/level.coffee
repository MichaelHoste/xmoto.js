class Level

  constructor: ->
    # Context
    canvas  = $('#game').get(0)
    @ctx = canvas.getContext('2d')

    # level unities * scale = pixels
    @scale =
      x:  100
      y: -100

    # Assets manager
    @assets        = new Assets()

    # Box2D World
    @physics       = new Physics(this)
    @world         = @physics.world

    # Inputs
    @input         = new Input(this)

    # Replay (for ghost)
    @replay        = new Replay(this)
    @ghost         = new Ghost(this, null)

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
    # Level dependent objects
    @infos        .parse(xml).init()
    @sky          .parse(xml).init()
    @blocks       .parse(xml).init()
    @limits       .parse(xml).init()
    @layer_offsets.parse(xml).init()
    @script       .parse(xml).init()
    @entities     .parse(xml).init()

    # Moto and ghosts (level independant)
    @moto.init()
    @ghost.init()

    @init_input()
    @init_sensors()

  init_canvas: ->
    @canvas  = $('#game').get(0)
    @canvas_width  = parseFloat(@canvas.width)
    @canvas_height = parseFloat(@canvas.height)

  init_input: ->
    @input.init()

  init_sensors: ->
    # Add listeners for end of level
    listener = new Box2D.Dynamics.b2ContactListener

    listener.BeginContact = (contact) =>
      a = contact.GetFixtureA().GetBody().GetUserData()
      b = contact.GetFixtureB().GetBody().GetUserData()
      if (a == 'moto' and b == 'end_of_level') || (a == 'rider' and b == 'end_of_level')
        @need_to_restart = true

    @world.SetContactListener(listener)

  display: ->
    if @need_to_restart
      @need_to_restart = false
      @restart(true)

    @init_canvas() if not @canvas
    $('#game').attr('height', @canvas_height)

    @ctx.translate(400.0, 300.0)
    @ctx.scale(@scale.x, @scale.y)
    @ctx.translate(-@moto.position().x, -@moto.position().y - 0.25)
    @ctx.lineWidth = 0.01

    @sky     .display(@ctx)
    @limits  .display(@ctx)
    @blocks  .display(@ctx)
    @entities.display(@ctx)
    @moto    .display(@ctx)
    @ghost   .display(@ctx) if @ghost

    # Save last step for replay
    @replay.add_frame()

  restart: (save_replay = false) ->
    if save_replay
      @ghost  = new Ghost(this, @replay.clone())
    @ghost.current_frame = 0
    @replay = new Replay(this)

    @moto.destroy()
    @moto = new Moto(this)
    @moto.init()
