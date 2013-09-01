$ ->
  level = new Level()
  level.load_from_file('l1038.lvl') # l9562.lvl  # l1287.lvl (snake) # l1038

  # Load assets for this level before doing anything else
  level.assets.load( ->
    update = ->
      level.world.Step(1 / 60,  10, 10)
      level.world.ClearForces()
      level.display()
      #level.world.DrawDebugData()

      # Initialize keyboard
      $(document).off('keydown')
      $(document).on('keydown', (event) =>
        force = 0.03
        left_wheel_body = level.moto.left_wheel
        right_wheel_body = level.moto.right_wheel
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

    # Render 2D environment
    setInterval(update, 1000 / 60)
  )

