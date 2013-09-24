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
    keys = [37, 38, 39, 40]

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
          @level.moto = new Moto(@level)
          @level.moto.init()
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

  move_moto: ->
    force = 24.1
    moto = @level.moto

    # Accelerate
    if @up
      moto.left_wheel.ApplyTorque(- force/3)

    # Brakes
    if @down
      # block right wheel velocity
      v_r = moto.right_wheel.GetAngularVelocity()
      moto.right_wheel.ApplyTorque((if Math.abs(v_r) >= 0.2 then -v_r))

      # block left wheel velocity
      v_l = moto.left_wheel.GetAngularVelocity()
      moto.left_wheel.ApplyTorque((if Math.abs(v_l) >= 0.2 then -v_l))

    # Back wheeling
    if @left
      moto.body.ApplyTorque(force/3)
      moto.rider.torso.ApplyTorque(force/3)

    # Front wheeling
    if @right
      moto.body.ApplyTorque(-force/3)
      moto.rider.torso.ApplyTorque(-force/3)

    # Engine brake
    if not @up and not @down
      v = moto.left_wheel.GetAngularVelocity()
      @level.moto.left_wheel.ApplyTorque((if Math.abs(v) >= 0.2 then -v/10))

    # Left wheel suspension
    moto.left_prismatic_joint.SetMaxMotorForce(8+Math.abs(800*Math.pow(moto.left_prismatic_joint.GetJointTranslation(), 2)))
    moto.left_prismatic_joint.SetMotorSpeed(-3*moto.left_prismatic_joint.GetJointTranslation())

    # Right wheel suspension
    moto.right_prismatic_joint.SetMaxMotorForce(4+Math.abs(800*Math.pow(moto.right_prismatic_joint.GetJointTranslation(), 2)))
    moto.right_prismatic_joint.SetMotorSpeed(-3*moto.right_prismatic_joint.GetJointTranslation())

