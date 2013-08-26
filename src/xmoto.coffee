$ ->
  SCALE = 30
  world = null

  init_game = ->
    box2dUtils = new window.Box2dUtils(SCALE)

    # Get Canvas and its attributes
    canvas       = $('#game').get(0)
    canvasWidth  = parseInt(canvas.width)
    canvasHeight = parseInt(canvas.height)
    context      = canvas.getContext('2d')

    world = box2dUtils.createWorld(context)

    # Create physical ground
    ground = box2dUtils.createBox(world, canvasWidth/2, canvasHeight-10, canvasWidth/2, 10, true, 'ground')

    # Create 2 static boxes
    staticBox  = box2dUtils.createBox(world, 600, 450, 50, 50, true, 'staticBox')
    staticBox2 = box2dUtils.createBox(world, 200, 250, 80, 30, true, 'staticBox2')

    # Create 2 static balls
    staticBall  = box2dUtils.createBall(world, 50, 400, 50, true, 'staticBall')
    staticBall2 = box2dUtils.createBall(world, 500, 150, 60, true, 'staticBall2')

    # Create 30 dynamic ball elements of different size
    for i in [0..29]
      radius = 45
      if i < 10
        radius = 15
      else if i < 20
        radius = 30;

      box2dUtils.createBall(world, Math.random()*canvasWidth, Math.random()*canvasHeight-400, radius, false, 'ball'+i)

    # Create 30 dynamic box elements of different size
    for i in [0..29]
      length = 45
      if i < 10
        length = 15
      else if i < 20
        length = 30

      box2dUtils.createBox(world, Math.random()*canvasWidth, Math.random()*canvasHeight-400, length, length, false, 'ball'+i)

    # Render 2D environment
    window.setInterval(update, 1000 / 60)

  # Mettre à jour le rendu de l'environnement 2d
  update = ->
    # update physics and canvas
    world.Step(1 / 60,  10, 10)
    world.DrawDebugData()
    world.ClearForces()

  #init_game()

