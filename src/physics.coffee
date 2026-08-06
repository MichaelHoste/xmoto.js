World    = planck.World
Vec2     = planck.Vec2
AABB     = planck.AABB
Chain    = planck.Chain
Circle   = planck.Circle
Polygon  = planck.Polygon
Settings = planck.Settings

class Physics

  constructor: (level) ->
    @level   = level
    @options = level.options
    @camera  = level.camera

    @world = new World(
      x:  0,
      y: -Constants.gravity
    )

    # Define physics (not directly correlated to FPS!)
    # --
    # For better physics, use 120 steps/s, it will make the moto more stable (but less fun?).
    # Don't try to increase iterations, more steps will have far more effect
    # --
    # For smoother motion in 120FPS screens, it's possible to interpolate positions using the remaining accumulator
    @step_ms             = 1000 / 60 # Fixed at 60 steps/s of physics (in ms), whatever the FPS loop
    @velocity_iterations = 10        # Default 8, a bit more was needed for less wobbly moto
    @position_iterations = 5         # Default 3, a bit more was needed for less wobbly moto

    # Debug canvas to validate physics shapes/joints (?debug=true&debug_physics=true)
    @debug_ctx = level.debug_ctx
    @debug_ctx.lineWidth = 0.03 # thickness of draw lines

    # Double default precision between wheel and ground (to avoid seing space between them)
    Settings.linearSlop = 0.0025

  init: ->
    @last_step_ms = performance.now()
    @steps        = 0

  restart: ->
    replay       = @level.replay
    player_ghost = @level.ghosts.player

    # save replay if better (local + server)
    if replay.success
      time = (replay.steps / 60.0).toFixed(2).replace('.', ':')
      if !player_ghost || player_ghost.replay.steps > replay.steps
        @save_replay_and_init_ghosts(replay)
        console.log("WIN : you improved your personal score : #{time} (#{replay.steps} steps)")
      else
        console.log("FAIL : you didn't improve your personal score : #{time} (#{replay.steps} steps)")

    @level.restart()
    @init()

  save_replay_and_init_ghosts: (replay) ->
    replay.add_step() # add last step
    replay.save()

    # Update replay of player ghost, or create new one
    if @level.ghosts.player
      @level.ghosts.player.replay = replay.clone()
      @level.ghosts.player.reload()
    else
      @level.ghosts.player = new Ghost(@level, replay.clone())
      @level.ghosts.player.init()

  update: ->
    while performance.now() - @last_step_ms > @step_ms
      @steps        += 1
      @last_step_ms += @step_ms

      @level.moto.move()
      @level.ghosts.move()
      @level.replay.add_step()
      @level.camera.move()

      # Cf. top of file and https://piqnt.com/planck.js/docs/world/simulation.html#simulating-the-world
      @world.step(@step_ms/1000, @velocity_iterations, @position_iterations)

      @level.input.space = false # Space can't stay pressed (used for `.move` and `.add_step`)

      if @level.need_to_restart
        @restart()
        @level.need_to_restart = false

    # For Gaffer's fixed timestep with interpolations:
    delta_ms = performance.now() - @last_step_ms # \ Leftover time not yet consumed by a full physics step (alpha is between 0.0 and 1.0)
    @alpha   = delta_ms / @step_ms               # | Could be used in moto.update() and rider.update() to adjust the position/angle of sprite
                                                 # | based on previous and current physics data (without updating the physics object!)
                                                 # / It would allow the game to go through 120fps with only 60 physics steps

  create_polygon: (vertices, name, density = 1.0, restitution = 0.5, friction = 1.0, group_index = -2) ->
    vertices = Physics.create_shape(vertices)
    shape    = new Polygon(vertices)

    body = @world.createBody(
      type: 'static'
      position:
        x: 0
        y: 0
      userData:
        name: name
    )

    body.createFixture(shape,
      density:          density
      restitution:      restitution
      friction:         friction
      filterGroupIndex: group_index
    )

  create_lines: (block, name, density = 1.0, restitution = 0.5, friction = 1.0, group_index = -2) ->
    return if !block.vertices.length

    # Some levels contain consecutive (near-)duplicate vertices, we remove them
    vertices = Physics.dedupe_vertices(block.vertices)

    # One closed Chain for the whole block outline. Chain automatically wires
    # up ghost vertices between adjacent segments, which suppresses edge collisions
    # that a set of disconnected segments would cause.
    shape = new Chain(vertices, true)

    body = @world.createBody(
      type: 'static'
      position:
        x: block.position.x
        y: block.position.y
      userData:
        name: name
    )

    body.createFixture(shape,
      density:          density
      restitution:      restitution
      friction:         friction
      filterGroupIndex: group_index
    )

  # Draw physics representation in debug context
  draw: ->
    service = new PhysicsDrawingService(@debug_ctx, @world)
    service.draw()

  # Remove consecutive (cyclic) vertices that are too close (or the same).
  # It will avoid zero-length edges that would crash Chain's construction.
  @dedupe_vertices: (vertices, distance = Settings.linearSlop) ->
    too_close = (a, b, distance) ->
      dx = a.x - b.x
      dy = a.y - b.y
      (dx * dx + dy * dy) < distance * distance

    deduped = []

    for vertex in vertices
      previous = deduped[deduped.length - 1]
      continue if previous? && too_close(previous, vertex, distance)
      deduped.push(vertex)

    # Repeatedly trim the wrap-around edge (last vertex back to the first),
    # since popping one duplicate can expose another.
    while deduped.length > 1 && too_close(deduped[0], deduped[deduped.length - 1], distance)
      deduped.pop()

    if deduped.length < 3
      throw new Error("dedupe_vertices: polygon degenerated to #{deduped.length} vertex(es) after removing duplicates")

    deduped

  # Dedupes and optionally mirrors (X-flip + winding reversal) a set of vertices
  # Currently used for moto parts and limits
  @create_shape: (vertices, mirror = false) ->
    vertices = Physics.dedupe_vertices(vertices)

    if mirror
      vertices.map((vertex) -> { x: -vertex.x, y: vertex.y })
    else
      vertices
