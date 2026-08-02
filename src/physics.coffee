b2World         = Box2D.Dynamics.b2World
b2Vec2          = Box2D.Common.Math.b2Vec2
b2AABB          = Box2D.Collision.b2AABB
b2BodyDef       = Box2D.Dynamics.b2BodyDef
b2Body          = Box2D.Dynamics.b2Body
b2FixtureDef    = Box2D.Dynamics.b2FixtureDef
b2Fixture       = Box2D.Dynamics.b2Fixture
b2MassData      = Box2D.Collision.Shapes.b2MassData
b2PolygonShape  = Box2D.Collision.Shapes.b2PolygonShape
b2CircleShape   = Box2D.Collision.Shapes.b2CircleShape
b2EdgeShape     = Box2D.Collision.Shapes.b2EdgeShape
b2EdgeChainDef  = Box2D.Collision.Shapes.b2EdgeChainDef
b2Contact       = Box2D.Dynamics.Contacts.b2Contact
b2DebugDraw     = Box2D.Dynamics.b2DebugDraw
b2MouseJointDef = Box2D.Dynamics.Joints.b2MouseJointDef
b2Settings      = Box2D.Common.b2Settings

class Physics

  # Per-`world.Step()` counter of Box2D TOI evaluations, and the cap beyond
  # which we consider the TOI solver to be thrashing (see the ComputeTOI
  # patch below). Static (class-level) since the patch lives on the shared
  # b2Contact.prototype.
  @toi_calls: 0
  @MAX_TOI_CALLS_PER_STEP: 1000

  constructor: (level) ->
    @level     = level
    @options   = level.options
    @camera    = level.camera
    @world     = new b2World(new b2Vec2(0, -Constants.gravity), true) # gravity vector, and doSleep
    @debug_ctx = level.debug_ctx

    # Double default precision between wheel and ground (to avoid seing space between them)
    b2Settings.b2_linearSlop = 0.0025

    # Box2D throws a bare string (`throw "Assertion Failed"`) on internal assertion failures.
    # It was hiding the full error stack, making it difficult to debug
    b2Settings.b2Assert = (condition) ->
      throw new Error("Box2D assertion failed") unless condition

    # Box2D's continuous-collision (TOI) solver has an unbounded `for(;;)` loop
    # (b2World::SolveTOI) that repeatedly recomputes the time of impact of the
    # closest contact until it's resolved. With levels made of many tiny/collinear
    # ground segments (one fixture per vertex pair, see `create_lines`), the wheel
    # can keep re-triggering near-zero-progress TOI events forever, freezing the
    # tab (found on e.g. l14104.lvl, l4132.lvl). There's no iteration cap in this
    # build of Box2D, so we add our own: count TOI evaluations per `world.Step()`
    # (reset in `update`) and bail out of the step if it's clearly thrashing.
    if !b2Contact.prototype._original_ComputeTOI
      b2Contact.prototype._original_ComputeTOI = b2Contact.prototype.ComputeTOI
      b2Contact.prototype.ComputeTOI = (sweepA, sweepB) ->
        Physics.toi_calls += 1
        if Physics.toi_calls > Physics.MAX_TOI_CALLS_PER_STEP
          throw new Error("Box2D TOI solver exceeded its per-step iteration budget (likely degenerate level geometry)")
        @_original_ComputeTOI(sweepA, sweepB)

    # Debug initialization
    debugDraw = new b2DebugDraw()
    debugDraw.SetSprite(@debug_ctx)                # context
    @debug_ctx.lineWidth = 0.03                    # thickness of line (debugDraw.SetLineThickness doesn't work)
    debugDraw.SetFillAlpha(0.5)                    # transparency
    debugDraw.m_sprite.graphics.clear = -> return; # Don't allow box2D to (badly) clear the canvas

    # Assign debug to world
    debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit)
    @world.SetDebugDraw(debugDraw)

    @world

  init: ->
    @last_step = new Date().getTime()
    @step      = 1000.0/Constants.fps
    @steps     = 0

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

  # Max physics steps to catch up on in a single update() call.
  # Without this cap, a slow world.Step() (huge level, slow device, tab
  # backgrounded...) can make the catch-up loop fall further behind on every
  # iteration than it recovers, freezing the browser tab forever ("spiral of
  # death"). We cap it instead, but *without* dropping the remaining backlog:
  # any leftover lag just carries over to the next update() call (next
  # `requestAnimationFrame`), so a long stall (e.g. an unfocused tab) is fully
  # caught up over a handful of frames instead of a) freezing the tab trying
  # to catch up in one go, or b) silently losing steps (which would desync
  # replays/ghosts from real elapsed time).
  MAX_STEPS_PER_UPDATE: 20

  update: ->
    loops = 0
    while (new Date()).getTime() - @last_step > @step and loops < @MAX_STEPS_PER_UPDATE
      loops += 1
      @steps = @steps + 1
      @last_step += @step

      @level.moto.move()
      @level.ghosts.move()
      @level.replay.add_step()
      @level.camera.move()

      Physics.toi_calls = 0
      try
        @world.Step(1.0/Constants.fps, 10, 10)
      catch e
        console.error("XMoto warning: #{e.message}")

      @world.ClearForces()
      @level.input.space = false # Space can't stay pressed (used for `.move` and `.add_step`)

      if @level.need_to_restart
        @restart()
        @level.need_to_restart = false

  create_polygon: (vertices, name, density = 1.0, restitution = 0.5, friction = 1.0, group_index = -2) ->
    # Create fixture
    fixDef = new b2FixtureDef()

    fixDef.shape             = new b2PolygonShape()
    fixDef.density           = density
    fixDef.restitution       = restitution
    fixDef.friction          = friction
    fixDef.filter.groupIndex = group_index

    # Create polygon
    Physics.create_shape(fixDef, vertices)

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = 0
    bodyDef.position.y = 0

    bodyDef.userData =
      name: name

    bodyDef.type = b2Body.b2_staticBody

    # Assign fixture to body and add body to 2D world
    @world.CreateBody(bodyDef).CreateFixture(fixDef)

  create_lines: (block, name, density = 1.0, restitution = 0.5, friction = 1.0, group_index = -2) ->
    return if !block.vertices.length

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = block.position.x
    bodyDef.position.y = block.position.y

    bodyDef.userData =
      name: name

    bodyDef.type = b2Body.b2_staticBody

    # add body to the world
    body = @world.CreateBody(bodyDef)

    # Some levels contain consecutive (near-)duplicate vertices, which would
    # produce a zero-length edge and crash Box2D's assertion.
    vertices = Physics.dedupe_vertices(block.vertices)

    # assign each couple of vertices to a line
    for vertex, i in vertices
      # Create fixture
      fixDef = new b2FixtureDef()

      fixDef.shape             = new b2PolygonShape()
      fixDef.density           = density
      fixDef.restitution       = restitution
      fixDef.friction          = friction
      fixDef.filter.groupIndex = group_index

      # Create line (from polygon because box2Dweb cannot do otherwise)
      vertex1 = vertex
      vertex2 = if i == vertices.length-1 then vertices[0] else vertices[i+1]
      fixDef.shape.SetAsArray([new b2Vec2(vertex1.x, vertex1.y), new b2Vec2(vertex2.x, vertex2.y)], 2)

      # Assign fixture (line) to body
      body.CreateFixture(fixDef)

  # Remove consecutive (cyclic) vertices that are too close (or the same).
  # It will avoid zero-length Box2D edges that would crash SetAsArray().
  @dedupe_vertices: (vertices, distance = 1e-9) ->
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

  @create_shape: (fix_def, vertices, mirror = false) ->
    vertices   = Physics.dedupe_vertices(vertices)
    b2vertices = []

    if mirror == false
      for vertex in vertices
        b2vertices.push(new b2Vec2(vertex.x, vertex.y))
    else
      for vertex in vertices
        b2vertices.unshift(new b2Vec2(-vertex.x, vertex.y))

    fix_def.shape.SetAsArray(b2vertices)
