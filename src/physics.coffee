Settings = planck.Settings
Vec2     = planck.Vec2

class Physics

  # Define physics (not directly correlated to FPS!)
  # --
  # More steps = more stable physics
  # 100 steps/s like Trackmania, 0.01s precision for level time
  # --
  # Use Gaffer's fixed timestep: https://gafferongames.com/post/fix_your_timestep/
  # with @alpha (0 <= α <= 1) to interpolate graphics positions for smoother rendering at any FPS
  STEPS_PER_SEC       = 100 # Like Trackmania, ideal for round 0.01 increment of replay time
  VELOCITY_ITERATIONS = 8   # Default 8 | => increasing may improve stability (less wobbly) but more stable physics objects could help too, with less computation
  POSITION_ITERATIONS = 3   # Default 3 /

  RECTANGLE_THICKNESS = 0.01 # 1cm

  CHAIN_SHARP_ANGLE = 170 # A turn this close to a full 180° reversal means the outline is folding on itself rather than curving.
                          # It creates physics bugs (like in l1187 when going left).
                          # We fix the (rare) bugs by splitting the chains at the sharp angles, and avoid looping.

  DEFAULT_FIXTURE =
    density:              1.0
    restitution:          0.5
    friction:             1.0
    is_sensor:            false # collisions by default (true has no collisions)
    filter_group_index:   0
    filter_category_bits: 0x0001
    filter_mask_bits:     0xFFFF

  constructor: (level) ->
    @level   = level
    @options = level.options
    @camera  = level.camera

    planck.Settings.linearSlop = 0.0025 # Force Planck.js double default precision between wheel and ground (to avoid seing space between them)

    @world = new planck.World(
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

  # Full circle that is entirely filled
  create_circle: (radius, position, angle = 0, type = 'static', user_data = {}, opts = {}) ->
    circle = new planck.Circle(radius)

    body = @world.createBody(
      type: type
      position:
        x: position.x
        y: position.y
      userData: user_data
    )

    body.createFixture(circle, @fixture_options(opts))

    body

  # Create collisions using decomposed convex polygons of maximum 12 vertices (SPLIT_MAX_VERTICES == Settings.MaxPolygonVertices).
  # Shape is entirely filled, collisions are only possible from the outside
  # Planck's Polygon silently takes the convex hull of whatever vertices it's given, so it must be decomposed first
  # => https://piqnt.com/planck.js/docs/shape/polygon.html
  # type should be in: static, kinematic, dynamic
  create_polygon: (vertices, position, angle = 0, type = 'static', user_data = {}, opts = {}) ->
    polygon = new Polygon(vertices)
    polygon.optimize() # remove duplicate/collinear

    if polygon.length() < 3
      console.error("XMoto error: can't create polygons collision with less than 3 vertices.")
      return

    body = @world.createBody(
      type: type
      position:
        x: position.x
        y: position.y
      angle: angle
      userData: user_data
    )

    for convex_polygon in polygon.decompose()
      for sub_polygon in convex_polygon.split() # default max vertices is 12 (SPLIT_MAX_VERTICES)
        shape = new planck.Polygon(sub_polygon.vertices)

        body.createFixture(shape, @fixture_options(opts))

    body

  # Create collisions using very thin rectangles following the edges, top-aligned on vertices.
  # Shape is hollow, collisions are possible from both ways
  create_polygon_with_rectangles: (vertices, position, angle = 0, type = 'static', user_data = {}, opts = {}) ->
    polygon = new Polygon(vertices)
    polygon.optimize() # remove duplicate/collinear

    if polygon.length() < 3
      console.error("XMoto error: can't create rectangles collision with less than 3 vertices.")
      return

    body = @world.createBody(
      type: type
      position:
        x: position.x
        y: position.y
      angle: angle
      userData: user_data
    )

    vertices = polygon.vertices

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
      shape = new planck.Polygon([
        Vec2(v1.x, v1.y)                     # Top-left
        Vec2(v2.x, v2.y)                     # Top-right
        Vec2(v2.x + offsetX, v2.y + offsetY) # Bottom-right
        Vec2(v1.x + offsetX, v1.y + offsetY) # Bottom-left
      ])

      body.createFixture(shape, @fixture_options(opts))

    body

  # Create collisions using individual Edges (without ghost vertices). May create ghost collisions
  # Shape is hollow, collisions are possible from both ways
  # => https://piqnt.com/planck.js/docs/shape/edge.html
  create_polygon_with_edges: (vertices, position, angle = 0, type = 'static', user_data = {}, opts = {}) ->
    polygon = new Polygon(vertices)
    polygon.optimize() # remove duplicate/collinear

    if polygon.length() < 3
      console.error("XMoto error: can't create edges collision with less than 3 vertices.")
      return

    body = @world.createBody(
      type: type
      position:
        x: position.x
        y: position.y
      angle: angle
      userData: user_data
    )

    vertices = polygon.vertices

    for vertex, i in vertices
      vertex1 = vertex
      vertex2 = if i == vertices.length - 1 then vertices[0] else vertices[i+1]

      shape = planck.Edge(Vec2(vertex1.x, vertex1.y), Vec2(vertex2.x, vertex2.y))

      body.createFixture(shape, @fixture_options(opts))

    body

  # Create collisions using Chains to avoid ghost collisions. If sharp angles, split the chains to avoid collision bug
  # Shape is hollow, collisions are possible from both ways
  # => https://piqnt.com/planck.js/docs/shape/edge.html
  create_polygon_with_chains: (vertices, position, angle = 0, type = 'static', user_data = {}, opts = {}) ->
    polygon = new Polygon(vertices)
    polygon.optimize() # remove duplicate/collinear

    if polygon.length() < 3
      console.error("XMoto error: can't create chains collision with less than 3 vertices.")
      return

    if polygon.self_intersect()
      console.warn("XMoto warning: polygon intersects itself and chains collisions may be bugged (not officially supported).") # See here: https://piqnt.github.io/planck.js/docs/shape/chain.html

    body = @world.createBody(
      type: type
      position:
        x: position.x
        y: position.y
      angle: angle
      userData: user_data
    )

    # Fix issues where very long, sharp edges may produce collision bug (cf. level 1187).
    # We detect those sharp angles and split the loop into separate non-looped Chains.
    # (these chains will appear without solid color in debug mode)
    chains = @split_at_sharp_folds(polygon.vertices, CHAIN_SHARP_ANGLE * Math.PI / 180)

    for chain in chains
      shape = new planck.Chain(chain.vertices, chain.is_loop)

      body.createFixture(shape, @fixture_options(opts))

    body

  fixture_options: (opts) ->
    return {
      density:            opts.density              ? DEFAULT_FIXTURE.density
      restitution:        opts.restitution          ? DEFAULT_FIXTURE.restitution
      friction:           opts.friction             ? DEFAULT_FIXTURE.friction
      isSensor:           opts.is_sensor            ? DEFAULT_FIXTURE.is_sensor
      filterGroupIndex:   opts.filter_group_index   ? DEFAULT_FIXTURE.filter_group_index
      filterCategoryBits: opts.filter_category_bits ? DEFAULT_FIXTURE.filter_category_bits
      filterMaskBits:     opts.filter_mask_bits     ? DEFAULT_FIXTURE.filter_mask_bits
    }

  # Splits a closed vertex loop into Chains, breaking it open at any vertex where the outline folds back close to 180°.
  # When there is nothing to fix, returns a single `is_loop: true` segment (the vertices untouched).
  split_at_sharp_folds: (vertices, sharp_angle_rad) ->
    n     = vertices.length
    folds = (i for i in [0...n] when Physics.sharp_fold(vertices, i, sharp_angle_rad))

    if folds.length == 0
      return [{ vertices: vertices, is_loop: true }]
    else
      for fold, k in folds
        next_fold = folds[(k + 1) % folds.length]
        { vertices: Physics.slice_cyclic(vertices, fold, next_fold), is_loop: false }

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
