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
        when 32
          @level.moto.flip()
        when 13
          @level.need_to_restart = true
        when 69 # e
          if !$('input').is(':focus')
            @level.moto.rider.eject()
        when 67 # c
          url = document.URL
          url = if url.substr(url.length-1) != '/' then "#{url}/capture" else "#{url}capture"
          $.post(url,
            steps: @level.physics.steps
            image: $(@level.options.canvas)[0].toDataURL()
          ).done( -> alert("Capture uploaded")).fail( -> alert("Capture failed"))
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
    moto   = @level.moto
    mirror = moto.mirror

    moto_acceleration = Constants.moto_acceleration
    biker_force       = Constants.biker_force

    if not @level.moto.dead
      # Accelerate
      if @up
        moto.left_wheel.ApplyTorque(- moto.mirror * moto_acceleration)

      # Brakes
      if @down
        # block wheels
        moto.right_wheel.SetAngularVelocity(0)
        moto.left_wheel.SetAngularVelocity(0)

      # Back wheeling
      if (@left && mirror == 1) || (@right && mirror == -1)
        moto.wheeling(biker_force)

      # Front wheeling
      if (@right && mirror == 1) || (@left && mirror == -1)
        biker_force = -biker_force * 0.8 # a bit less force for front wheeling
        moto.wheeling(biker_force)

    # Detection of drifting
    #rotation_speed = -(moto.left_wheel.GetAngularVelocity()*Math.PI/180)*2*Math.PI*Constants.left_wheel.radius
    #linear_speed   = moto.left_wheel.GetLinearVelocity().x/10
    #if linear_speed > 0 and rotation_speed > 1.5*linear_speed
    #  @level.particles.create()
