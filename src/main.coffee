$ ->
  level = new Level()
  level.load_from_file('l1038.lvl') # l9562.lvl  # l1287.lvl (snake) # l1038
  level.assets.load( ->
    level.display()

    physics = new Physics(30)
    world = physics.createWorld(level.ctx)

    ball   = physics.createBall(world, 1, 7, 1, false, 'ball'+i)
    for triangle in level.blocks.triangles
      physics.createTriangle(world, triangle, true, [])

    # Mettre à jour le rendu de l'environnement 2d
    update = ->
      # update physics and canvas
      level.display()
      world.Step(1 / 60,  10, 10)
      world.DrawDebugData()
      world.ClearForces()

    # Render 2D environment
    setInterval(update, 1000 / 60)
  )
