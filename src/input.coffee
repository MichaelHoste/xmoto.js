class Input

  constructor: (level) ->
    @level  = level
    @assets = level.assets

  init: ->
    @disable_scroll()
    @init_keyboard()

  disable_scroll: ->
    # Disable up, down, left, right to scroll
    # left: 37, up: 38, right: 39, down: 40, spacebar: 32, pageup: 33, pagedown: 34, end: 35, home: 36
    keys = [37, 38, 39, 40, 32]

    preventDefault = (e) ->
      e = e || window.event
      if e.preventDefault
        e.preventDefault()
      e.returnValue = false

    keydown = (e) ->
      for i in keys
        if e.keyCode == i
          preventDefault(e)
          return

    document.onkeydown = keydown

  init_keyboard: ->
    $(document).off('keydown')
    $(document).on('keydown', (event) =>
      switch(event.which || event.keyCode)
        when 38
          @up = true
        when 40
          @down = true
        when 37
          @left = true
        when 39
          @right = true
        when 13
          @level.need_to_restart = true
        when 32
          @level.flip_moto() if not @level.moto.dead
        when 67
          url = document.URL
          url = if url.substr(url.length-1) != '/' then "#{url}/capture" else "#{url}capture"
          $.post(url,
            steps: @level.physics.steps
            image: $("#game")[0].toDataURL()
          ).done( -> console.log("Capture uploaded")).fail( -> console.log("Capture failed"))
    )

    $(document).on('keyup', (event) =>
      switch(event.which || event.keyCode)
        when 38
          @up = false
        when 40
          @down = false
        when 37
          @left = false
        when 39
          @right = false
    )

  move: ->
    force = 24.1
    moto  = @level.moto
    rider = moto.rider

    if not @level.moto.dead
      # Accelerate
      if @up
        moto.left_wheel.ApplyTorque(- moto.mirror * force/3)

      # Brakes
      if @down
        # block wheels
        moto.right_wheel.SetAngularVelocity(0)
        moto.left_wheel.SetAngularVelocity(0)

      # Back wheeling
      if @left
        moto.body            .ApplyTorque(    force/3.0)
        moto.rider.torso     .ApplyTorque(    force/8.0)
        moto.rider.torso     .ApplyForce({x: -force/4.0, y: 0}, moto.rider.torso    .GetWorldCenter())
        moto.rider.lower_leg .ApplyForce({x:  force/4.0, y: 0}, moto.rider.lower_leg.GetWorldCenter())

      # Front wheeling
      if @right
        moto.body            .ApplyTorque(   -force/3.0)
        moto.rider.torso     .ApplyTorque(   -force/8.0)
        moto.rider.torso     .ApplyForce({x:  force/4.0, y: 0}, moto.rider.torso    .GetWorldCenter())
        moto.rider.lower_leg .ApplyForce({x: -force/4.0, y :0}, moto.rider.lower_leg.GetWorldCenter())

    if not @up and not @down
      # Engine brake
      v = moto.left_wheel.GetAngularVelocity()
      moto.left_wheel.ApplyTorque((if Math.abs(v) >= 0.2 then -v/10))

      # Friction on right wheel
      v = moto.right_wheel.GetAngularVelocity()
      moto.right_wheel.ApplyTorque((if Math.abs(v) >= 0.2 then -v/100))

    # Left wheel suspension
    moto.left_prismatic_joint.SetMaxMotorForce(8+Math.abs(800*Math.pow(moto.left_prismatic_joint.GetJointTranslation(), 2)))
    moto.left_prismatic_joint.SetMotorSpeed(-3*moto.left_prismatic_joint.GetJointTranslation())

    # Right wheel suspension
    moto.right_prismatic_joint.SetMaxMotorForce(4+Math.abs(800*Math.pow(moto.right_prismatic_joint.GetJointTranslation(), 2)))
    moto.right_prismatic_joint.SetMotorSpeed(-3*moto.right_prismatic_joint.GetJointTranslation())

    # Drag (air resistance)
    air_density        = Constants.air_density
    object_penetration = 0.025
    squared_speed      = Math.pow(moto.body.GetLinearVelocity().x, 2)
    drag_force         = air_density * squared_speed * object_penetration
    moto.body.SetLinearDamping(drag_force)

    # Limitation of wheel rotation speed (and by extension, of moto)
    if moto.right_wheel.GetAngularVelocity() > Constants.max_moto_speed
      moto.right_wheel.SetAngularVelocity(Constants.max_moto_speed)
    else if moto.right_wheel.GetAngularVelocity() < -Constants.max_moto_speed
      moto.right_wheel.SetAngularVelocity(-Constants.max_moto_speed)

    if moto.left_wheel.GetAngularVelocity() > Constants.max_moto_speed
      moto.left_wheel.SetAngularVelocity(Constants.max_moto_speed)
    else if moto.left_wheel.GetAngularVelocity() < -Constants.max_moto_speed
      moto.left_wheel.SetAngularVelocity(-Constants.max_moto_speed)

    # Detection of drifting
    #rotation_speed = -(moto.left_wheel.GetAngularVelocity()*Math.PI/180)*2*Math.PI*Constants.left_wheel.radius
    #linear_speed   = moto.left_wheel.GetLinearVelocity().x/10
    #if linear_speed > 0 and rotation_speed > 1.5*linear_speed
    #  @level.particles.create()
