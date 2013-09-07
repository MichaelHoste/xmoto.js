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
    # Initialize keyboard
    $(document).off('keydown')
    $(document).on('keydown', (event) =>
      force = 0.03
      left_wheel_body = @level.moto.left_wheel
      right_wheel_body = @level.moto.right_wheel
      switch(event.which || event.keyCode)
        when 38 # up
          left_wheel_body.ApplyTorque(- 0.001)
          #left_wheel_body.ApplyForce(new b2Vec2(  force/2, 0), left_wheel_body.GetWorldCenter())
        when 40 # down
          left_wheel_body.ApplyTorque(0.001)
          #left_wheel_body.ApplyForce(new b2Vec2( -force/2, 0), left_wheel_body.GetWorldCenter())
        when 37 # left
          right_wheel_body.ApplyForce(new b2Vec2( 0, -force), right_wheel_body.GetWorldCenter())
        when 39 # right
          right_wheel_body.ApplyForce(new b2Vec2( 0,  force), right_wheel_body.GetWorldCenter())
    )
