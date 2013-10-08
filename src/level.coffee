b2Vec2 = Box2D.Common.Math.b2Vec2

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
    @ctx.lineWidth = 0.01

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
      else if a == 'rider' and b == 'ground'
        @moto.dead = true

        @world.DestroyJoint(@moto.rider.ankle_joint)
        @world.DestroyJoint(@moto.rider.wrist_joint)

        @moto.rider.knee_joint.m_lowerAngle     = @moto.rider.knee_joint.m_lowerAngle * 1.5
        @moto.rider.elbow_joint.m_upperAngle    = @moto.rider.elbow_joint.m_upperAngle * 1.5
        @moto.rider.shoulder_joint.m_upperAngle = @moto.rider.shoulder_joint.m_upperAngle * 1.5
        @moto.rider.hip_joint.m_lowerAngle      = @moto.rider.hip_joint.m_lowerAngle * 1.5

    @world.SetContactListener(listener)

  display: (debug = false) ->
    if @need_to_restart
      @need_to_restart = false
      @restart(true)

    @init_canvas() if not @canvas
    @ctx.clearRect(0, 0, @canvas_width, @canvas_height)

    @ctx.save()

    # initialize position of camera
    @ctx.translate(@canvas_width/2, @canvas_height/2)               # Center of canvas
    @ctx.scale(@scale.x, @scale.y)                                  # Scale (zoom)
    @ctx.translate(-@moto.position().x, -@moto.position().y - 0.25) # Camera on moto

    @sky     .display(@ctx)
    @limits  .display(@ctx)
    @entities.display_sprites(@ctx)
    @blocks  .display(@ctx)
    @entities.display_items(@ctx)
    @moto    .display(@ctx)
    @ghost   .display(@ctx) if @ghost

    @world.DrawDebugData() if debug

    @ctx.restore()

    # Save last step for replay
    @replay.add_frame()

  flip_moto: ->
    @moto = MotoFlip.execute(@moto)

  restart: (save_replay = false) ->
    if save_replay
      if (not @ghost.replay) or @ghost.replay.frames_count() > @replay.frames_count()
        @ghost  = new Ghost(this, @replay.clone())
    @ghost.current_frame = 0
    @replay = new Replay(this)

    @moto.destroy()
    @moto = new Moto(this, false)
    @moto.init()
