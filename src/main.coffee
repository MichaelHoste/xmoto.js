$ ->
  level = new Level()
  level.load_from_file('l3.lvl') # l9562.lvl  # l1287.lvl (snake) # l1038 #l3.lvl

  # Load assets for this level before doing anything else
  level.assets.load( ->
    update = ->
      level.input.move_moto()
      level.world.Step(1.0 / 60.0, 10, 10)
      level.world.ClearForces()
      level.display(false)

    # Render 2D environment
    setInterval(update, 1000 / 60)
  )

