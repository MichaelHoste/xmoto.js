class Input

  constructor: (level) ->
    @level  = level
    @assets = level.assets

  init: ->
    @disable_scroll()
    @init_keyboard()
    @init_zoom()

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
          @level.restart()
        when 32
          @level.flip_moto() if not @level.moto.dead
        when 85 # u
          switch(@level.get_render_mode())
            when "normal"   then @level.set_render_mode("ugly")
            when "ugly"     then @level.set_render_mode("uglyOver")
            when "uglyOver" then @level.set_render_mode("normal")
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

  # If there are some issues on other systems than MacOS,
  # check this to find a solution : http://stackoverflow.com/questions/5527601/normalizing-mousewheel-speed-across-browsers
  init_zoom: ->
    scroll = (event) =>
      if event.wheelDelta
        delta = event.wheelDelta/40
      else if event.detail
        delta = -event.detail
      else
        delta = 0

      # zoom / dezoom
      @level.scale.x += (@level.scale.x/200) * delta
      @level.scale.y += (@level.scale.y/200) * delta

      # boundaries
      @level.scale.x =  35 if @level.scale.x <  35
      @level.scale.y = -35 if @level.scale.y > -35

      @level.scale.x =  200 if @level.scale.x >  200
      @level.scale.y = -200 if @level.scale.y < -200

      return event.preventDefault() && false

    canvas = $('#game').get(0)
    canvas.addEventListener('DOMMouseScroll', scroll, false)
    canvas.addEventListener('mousewheel',     scroll, false)

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
        moto.body.ApplyTorque(force/3.0)
        moto.rider.torso.ApplyTorque(force/3.0)

      # Front wheeling
      if @right
        moto.body.ApplyTorque(-force/3.0)
        moto.rider.torso.ApplyTorque(-force/3.0)

    if not @up and not @down
      # Engine brake
      v = moto.left_wheel.GetAngularVelocity()
      @level.moto.left_wheel.ApplyTorque((if Math.abs(v) >= 0.2 then -v/10))

      # Friction on right wheel
      v = moto.right_wheel.GetAngularVelocity()
      @level.moto.right_wheel.ApplyTorque((if Math.abs(v) >= 0.2 then -v/100))

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
