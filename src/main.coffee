$ ->
  level = new Level()
  level.load_from_file('l374.lvl') # l9562.lvl  # l1287.lvl (snake) # l1038 #l3.lvl # l1041 (jumps), l1042, l1043 #l74

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

