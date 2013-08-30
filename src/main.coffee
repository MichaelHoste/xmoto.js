$ ->
  level = new Level()
  level.load_from_file('l1038.lvl') # l9562.lvl  # l1287.lvl (snake) # l1038
  level.assets.load( ->
    level.display()

    ball = level.physics.createBall(1, 7, 1, false, 'wheel1')

    # Mettre à jour le rendu de l'environnement 2d
    update = ->
      # update physics and canvas
      level.display()
      level.world.Step(1 / 60,  10, 10)
      level.world.DrawDebugData()
      level.world.ClearForces()

      # Initialize keyboard
      $(document).off('keydown')
      $(document).on('keydown', (event) =>
        force = 0.3
        switch(event.which || event.keyCode)
          when 38 then ball.GetBody().ApplyForce(new b2Vec2( 0,     force), ball.GetBody().GetWorldCenter()) # up
          when 40 then ball.GetBody().ApplyForce(new b2Vec2( 0,    -force), ball.GetBody().GetWorldCenter()) # down
          when 37 then ball.GetBody().ApplyTorque(0.01) # left
          when 39 then ball.GetBody().ApplyTorque(- 0.01) # right
      )

    # Render 2D environment
    setInterval(update, 1000 / 60)
  )
