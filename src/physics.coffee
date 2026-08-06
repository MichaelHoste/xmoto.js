World    = planck.World
Vec2     = planck.Vec2
Chain    = planck.Chain
Circle   = planck.Circle
Polygon  = planck.Polygon
Settings = planck.Settings

class Physics

  # Define physics (not directly correlated to FPS!)
  # --
  # More steps = more stable physics
  # Don't try to increase iterations, more steps have far more effect.
  # --
  # Use Gaffer's fixed timestep: https://gafferongames.com/post/fix_your_timestep/
  # with @alpha (0 <= α <= 1) to interpolate graphics positions for smoother rendering at any FPS
  STEPS_PER_SEC       = 100 # Like Trackmania, ideal for round 0.01 increment of replay time
  VELOCITY_ITERATIONS = 8   # Default 8
  POSITION_ITERATIONS = 3   # Default 3

  RECTANGLE_THICKNESS = 0.01 # 1cm

  CHAIN_SHARP_ANGLE = 170 # A turn this close to a full 180° reversal means the outline is folding on itself rather than curving.
                          # It creates physics bugs (like in l1187 when going left).
                          # We fix the (rare) bugs by splitting the chains at the sharp angles, and avoid looping.

  DEFAULT_FIXTURE_OPTS =
    density:          1.0
    restitution:      0.5
    friction:         1.0
    filterGroupIndex: -2

  constructor: (level) ->
    @level   = level
    @options = level.options
    @camera  = level.camera

    Settings.linearSlop = 0.0025 # Force Planck.js double default precision between wheel and ground (to avoid seing space between them)

    @world = new World(
      x:  0,
      y: -Constants.gravity
    )

    @physics_drawing_service = new PhysicsDrawingService(@level.debug_ctx, @world)

  init: ->
    @last_step_ms = performance.now()
    @steps        = 0
    @step_ms      = 1000 / STEPS_PER_SEC # Time in ms of a single step

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
      @world.step(1 / STEPS_PER_SEC, VELOCITY_ITERATIONS, POSITION_ITERATIONS)

      @level.input.space = false # Space can't stay pressed (used for `.move` and `.add_step`)

      if @level.need_to_restart
        @restart()
        @level.need_to_restart = false

    # For Gaffer's fixed timestep
    delta_ms = performance.now() - @last_step_ms # \ Leftover time not yet consumed by a full physics step (alpha is between 0.0 and 1.0)
    @alpha   = delta_ms / @step_ms               # | Could be used in moto.update() and rider.update() to adjust the position/angle of sprite
                                                 # | based on previous and current physics data (without updating the physics object!)
                                                 # / It would allow the game to go through 120fps with only 60 physics steps

  # Draw physics representation in debug context
  draw: ->
    @physics_drawing_service.draw()

  # Create collisions using polygons.
  # Shape is entirely filled. Any convex point will be removed by Planck!
  # TODO HERE: decomp.decomp(pairs) then loop and create several sub-polygons
  # => https://piqnt.com/planck.js/docs/shape/polygon.html
  create_polygons_collisions: (position, vertices, name, opts = {}) ->
    vertices = Physics.optimize_vertices(vertices)
    return if vertices.length < 3

    body = @world.createBody(
      type: 'static'
      position:
        x: position.x
        y: position.y
      userData:
        name: name
    )

    shape = new Polygon(vertices)

    body.createFixture(shape,
      density:          opts.density     ? DEFAULT_FIXTURE_OPTS.density
      restitution:      opts.restitution ? DEFAULT_FIXTURE_OPTS.restitution
      friction:         opts.friction    ? DEFAULT_FIXTURE_OPTS.friction
      filterGroupIndex: opts.group_index ? DEFAULT_FIXTURE_OPTS.group_index
    )

  # Create collisions using very thin rectangles following the edges, top-aligned on vertices.
  # Shape is hollow, collisions are possible from both ways
  create_rectangles_collisions: (position, vertices, name, opts = {}) ->
    vertices = Physics.optimize_vertices(vertices)
    return if !vertices.length

    body = @world.createBody(
      type: 'static'
      position:
        x: position.x
        y: position.y
      userData:
        name: name
    )

    for vertex, i in vertices
      v1 = vertex
      v2 = if i == vertices.length - 1 then vertices[0] else vertices[i+1]

      dx     = v2.x - v1.x
      dy     = v2.y - v1.y
      length = Math.hypot(dx, dy)

      # Unit vector perpendicular oriented to the right (toward the "bottom" of the segment v1->v2)
      px =  dy / length
      py = -dx / length

      # Vector shift across the entire rectangle thickness
      offsetX =  dy / length * RECTANGLE_THICKNESS
      offsetY = -dx / length * RECTANGLE_THICKNESS

      # Create line using an Polygon shape of minimal thickness
      shape = new Polygon([
        planck.Vec2(v1.x, v1.y)                     # Top-left
        planck.Vec2(v2.x, v2.y)                     # Top-right
        planck.Vec2(v2.x + offsetX, v2.y + offsetY) # Bottom-right
        planck.Vec2(v1.x + offsetX, v1.y + offsetY) # Bottom-left
      ])

      body.createFixture(shape,
        density:          opts.density     ? DEFAULT_FIXTURE_OPTS.density
        restitution:      opts.restitution ? DEFAULT_FIXTURE_OPTS.restitution
        friction:         opts.friction    ? DEFAULT_FIXTURE_OPTS.friction
        filterGroupIndex: opts.group_index ? DEFAULT_FIXTURE_OPTS.group_index
      )

  # Create collisions using individual Edges (without ghost vertices). May create ghost collisions
  # Shape is hollow, collisions are possible from both ways
  # => https://piqnt.com/planck.js/docs/shape/edge.html
  create_edges_collisions: (position, vertices, name, opts = {}) ->
    vertices = Physics.optimize_vertices(vertices)
    return if !vertices.length

    body = @world.createBody(
      type: 'static'
      position:
        x: position.x
        y: position.y
      userData:
        name: name
    )

    for vertex, i in vertices
      vertex1 = vertex
      vertex2 = if i == vertices.length - 1 then vertices[0] else vertices[i+1]

      shape = planck.Edge(planck.Vec2(vertex1.x, vertex1.y), planck.Vec2(vertex2.x, vertex2.y))

      body.createFixture(shape,
        density:          opts.density     ? DEFAULT_FIXTURE_OPTS.density
        restitution:      opts.restitution ? DEFAULT_FIXTURE_OPTS.restitution
        friction:         opts.friction    ? DEFAULT_FIXTURE_OPTS.friction
        filterGroupIndex: opts.group_index ? DEFAULT_FIXTURE_OPTS.group_index
      )

  # Create collisions using Chains to avoid ghost collisions. If sharp angles, split the chains to avoid collision bug
  # Shape is hollow, collisions are possible from both ways
  # => https://piqnt.com/planck.js/docs/shape/edge.html
  create_chains_collisions: (position, vertices, name, opts = {}) ->
    vertices = Physics.optimize_vertices(vertices)
    return if vertices.length < 3

    body = @world.createBody(
      type: 'static'
      position:
        x: position.x
        y: position.y
      userData:
        name: name
    )

    # Fix issues where very long, sharp edges may produce collision bug (cf. level 1187).
    # We detect those sharp angles and split the loop into separate non-looped Chains.
    # (these chains will appear without solid color in debug mode)
    chains = @split_at_sharp_folds(vertices, CHAIN_SHARP_ANGLE * Math.PI / 180)

    for chain in chains
      shape = new Chain(chain.vertices, chain.is_loop)

      body.createFixture(shape,
        density:          opts.density     ? DEFAULT_FIXTURE_OPTS.density
        restitution:      opts.restitution ? DEFAULT_FIXTURE_OPTS.restitution
        friction:         opts.friction    ? DEFAULT_FIXTURE_OPTS.friction
        filterGroupIndex: opts.group_index ? DEFAULT_FIXTURE_OPTS.group_index
      )

  # Splits a closed vertex loop into Chains, breaking it open at any vertex where the outline folds back close to 180°.
  # Returns a single `is_loop: true` segment (the vertices untouched) when there is nothing to fix.
  split_at_sharp_folds: (vertices, sharp_angle_rad) ->
    n     = vertices.length
    folds = (i for i in [0...n] when Physics.sharp_fold(vertices, i, sharp_angle_rad))

    if folds.length == 0
      return [{ vertices: vertices, is_loop: true }]
    else
      for fold, k in folds
        next_fold = folds[(k + 1) % folds.length]
        { vertices: Physics.slice_cyclic(vertices, fold, next_fold), is_loop: false }

  # Some levels contain consecutive (near-)duplicate vertices, which would
  # produce a zero-length edge and crash Planck's assertion.
  @optimize_vertices: (vertices) ->
    vertices = Physics.remove_duplicate_vertices(vertices)
    vertices = Physics.remove_collinear_vertices(vertices)
    vertices = Physics.check_intersect_vertices(vertices)  # Does not fix, only triggers warning
    vertices

  # Remove consecutive (cyclic) vertices that are too close (or the same).
  # It will avoid zero-length edges that would crash Chain's construction.
  @remove_duplicate_vertices: (vertices, distance = Settings.linearSlop) ->
    pairs = vertices.map((vertex) -> [vertex.x, vertex.y])

    decomp.removeDuplicatePoints(pairs, distance)

    if vertices.length == pairs.length
      return vertices # nothing was removed
    else
      if pairs.length < 3
        console.error("XMoto warning: polygon degenerated from #{vertices.length} to #{pairs.length} vertex(es) after removing duplicates, and was ignored.")
      else
        console.warn("XMoto warning: #{vertices.length - pairs.length} duplicate vertices have been removed.")

      return pairs.map((pair) -> { x: pair[0], y: pair[1] })

  # Removes collinear points in the polygon. This means that if three points are placed along the same line, the middle one will be removed.
  # The angle_rad determines whether the points are collinear or not.
  @remove_collinear_vertices: (vertices, angle_rad =  0.01) -> # 0.01 = ~0.5°
    pairs = vertices.map((vertex) -> [vertex.x, vertex.y])

    decomp.removeCollinearPoints(pairs, angle_rad)

    if vertices.length == pairs.length
      return vertices # nothing was removed
    else
      if pairs.length < 3
        console.error("XMoto warning: polygon degenerated from #{vertices.length} to #{pairs.length} vertex(es) after removing collinear, and was ignored.")
      else
        console.warn("XMoto warning: #{vertices.length - pairs.length} collinear vertices have been removed.")

      return pairs.map((pair) -> { x: pair[0], y: pair[1] })

  # Detect polygons where the vertices intersect themselves
  @check_intersect_vertices: (vertices) ->
    pairs = vertices.map((vertex) -> [vertex.x, vertex.y])

    if !decomp.isSimple(pairs)
      console.warn("XMoto warning: polygon intersects itself and collisions may be bugged (not officially supported).") # See here: https://piqnt.github.io/planck.js/docs/shape/chain.html

    vertices

  @sharp_fold: (vertices, i, sharp_angle_rad) ->
    Math.abs(Physics.turn_angle(vertices, i)) > sharp_angle_rad

  # Signed angle (radians) between the incoming and outgoing edge at vertices[i]
  @turn_angle: (vertices, i) ->
    n    = vertices.length
    prev = vertices[(i - 1 + n) % n]
    cur  = vertices[i]
    next = vertices[(i + 1) % n]

    d_in  = { x: cur.x  - prev.x, y: cur.y  - prev.y }
    d_out = { x: next.x - cur.x,  y: next.y - cur.y  }

    cross = d_in.x * d_out.y - d_in.y * d_out.x
    dot   = d_in.x * d_out.x + d_in.y * d_out.y

    Math.atan2(cross, dot)

  # Vertices from index `from` to `to` (inclusive), walking forward cyclically.
  # A full lap around the loop when `from == to` (there's exactly one fold, so
  # the segment must cover the whole outline, not a single point).
  @slice_cyclic: (vertices, from, to) ->
    n     = vertices.length
    steps = (to - from + n) % n
    steps = n if steps == 0

    (vertices[(from + step) % n] for step in [0..steps])

  # Dedupes and optionally mirrors a set of vertices.
  # Currently used for moto parts and limits
  @create_shape: (vertices, mirror = false) ->
    vertices = Physics.optimize_vertices(vertices)

    if mirror
      vertices.map((vertex) -> { x: -vertex.x, y: vertex.y })
    else
      vertices
