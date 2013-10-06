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
    @blocks  .display(@ctx)
    @entities.display(@ctx)
    @moto    .display(@ctx)
    @ghost   .display(@ctx) if @ghost

    @world.DrawDebugData() if debug

    @ctx.restore()

    # Save last step for replay
    @replay.add_frame()

  flip_moto: ->
    body =
      position: @moto.body.GetPosition()
      angle:    @moto.body.GetAngle()
      linear:   @moto.body.GetLinearVelocity()
      angular:  @moto.body.GetAngularVelocity()

    left_wheel =
      position: @moto.left_wheel.GetPosition()
      angle:    @moto.left_wheel.GetAngle()
      linear:   @moto.left_wheel.GetLinearVelocity()
      angular:  @moto.left_wheel.GetAngularVelocity()

    right_wheel =
      position: @moto.right_wheel.GetPosition()
      angle:    @moto.right_wheel.GetAngle()
      linear:   @moto.right_wheel.GetLinearVelocity()
      angular:  @moto.right_wheel.GetAngularVelocity()

    left_axle =
      position: @moto.left_axle.GetPosition()
      angle:    @moto.left_axle.GetAngle()
      linear:   @moto.left_axle.GetLinearVelocity()
      angular:  @moto.left_axle.GetAngularVelocity()

    right_axle =
      position: @moto.right_axle.GetPosition()
      angle:    @moto.right_axle.GetAngle()
      linear:   @moto.right_axle.GetLinearVelocity()
      angular:  @moto.right_axle.GetAngularVelocity()

    torso =
      position: @moto.rider.torso.GetPosition()
      angle:    @moto.rider.torso.GetAngle()
      linear:   @moto.rider.torso.GetLinearVelocity()
      angular:  @moto.rider.torso.GetAngularVelocity()

    lower_leg =
      position: @moto.rider.lower_leg.GetPosition()
      angle:    @moto.rider.lower_leg.GetAngle()
      linear:   @moto.rider.lower_leg.GetLinearVelocity()
      angular:  @moto.rider.lower_leg.GetAngularVelocity()

    upper_leg =
      position: @moto.rider.upper_leg.GetPosition()
      angle:    @moto.rider.upper_leg.GetAngle()
      linear:   @moto.rider.upper_leg.GetLinearVelocity()
      angular:  @moto.rider.upper_leg.GetAngularVelocity()

    lower_arm =
      position: @moto.rider.lower_arm.GetPosition()
      angle:    @moto.rider.lower_arm.GetAngle()
      linear:   @moto.rider.lower_arm.GetLinearVelocity()
      angular:  @moto.rider.lower_arm.GetAngularVelocity()

    upper_arm =
      position: @moto.rider.upper_arm.GetPosition()
      angle:    @moto.rider.upper_arm.GetAngle()
      linear:   @moto.rider.upper_arm.GetLinearVelocity()
      angular:  @moto.rider.upper_arm.GetAngularVelocity()

    mirror = @moto.mirror == 1
    @moto.destroy()
    @moto = new Moto(this, mirror)
    @moto.init()

    @moto.body           .SetPosition(body.position)
    @moto.body           .SetAngle(body.angle)
    @moto.body           .SetLinearVelocity(body.linear)
    @moto.body           .SetAngularVelocity(body.angular)

    @moto.left_wheel     .SetPosition(right_wheel.position)
    @moto.left_wheel     .SetAngle(left_wheel.angle)
    @moto.left_wheel     .SetLinearVelocity(left_wheel.linear)
    @moto.left_wheel     .SetAngularVelocity(left_wheel.angular)

    @moto.right_wheel    .SetPosition(left_wheel.position)
    @moto.right_wheel    .SetAngle(right_wheel.angle)
    @moto.right_wheel    .SetLinearVelocity(right_wheel.linear)
    @moto.right_wheel    .SetAngularVelocity(right_wheel.angular)

    @moto.left_axle      .SetPosition(left_axle.position)
    @moto.left_axle      .SetAngle(left_axle.angle)
    @moto.left_axle      .SetLinearVelocity(left_axle.linear)
    @moto.left_axle      .SetAngularVelocity(left_axle.angular)

    @moto.right_axle     .SetPosition(right_axle.position)
    @moto.right_axle     .SetAngle(right_axle.angle)
    @moto.right_axle     .SetLinearVelocity(right_axle.linear)
    @moto.right_axle     .SetAngularVelocity(right_axle.angular)

    @moto.rider.torso    .SetPosition(torso.position)
    @moto.rider.torso    .SetAngle(torso.angle)
    @moto.rider.torso    .SetLinearVelocity(torso.linear)
    @moto.rider.torso    .SetAngularVelocity(torso.angular)

    @moto.rider.lower_leg.SetPosition(lower_leg.position)
    @moto.rider.lower_leg.SetAngle(lower_leg.angle)
    @moto.rider.lower_leg.SetLinearVelocity(lower_leg.linear)
    @moto.rider.lower_leg.SetAngularVelocity(lower_leg.angular)

    @moto.rider.upper_leg.SetPosition(upper_leg.position)
    @moto.rider.upper_leg.SetAngle(upper_leg.angle)
    @moto.rider.upper_leg.SetLinearVelocity(upper_leg.linear)
    @moto.rider.upper_leg.SetAngularVelocity(upper_leg.angular)

    @moto.rider.lower_arm.SetPosition(lower_arm.position)
    @moto.rider.lower_arm.SetAngle(lower_arm.angle)
    @moto.rider.lower_arm.SetLinearVelocity(lower_arm.linear)
    @moto.rider.lower_arm.SetAngularVelocity(lower_arm.angular)

    @moto.rider.upper_arm.SetPosition(upper_arm.position)
    @moto.rider.upper_arm.SetAngle(upper_arm.angle)
    @moto.rider.upper_arm.SetLinearVelocity(upper_arm.linear)
    @moto.rider.upper_arm.SetAngularVelocity(upper_arm.angular)

  restart: (save_replay = false) ->
    if save_replay
      if (not @ghost.replay) or @ghost.replay.frames_count() > @replay.frames_count()
        @ghost  = new Ghost(this, @replay.clone())
    @ghost.current_frame = 0
    @replay = new Replay(this)

    @moto.destroy()
    @moto = new Moto(this, false)
    @moto.init()
