World  = planck.World
Vec2   = planck.Vec2
AABB   = planck.AABB
Chain  = planck.Chain
Circle = planck.Circle
Polygon = planck.Polygon
Settings = planck.Settings

class Physics

  constructor: (level) ->
    @level     = level
    @options   = level.options
    @camera    = level.camera
    @world     = new World({x: 0, y: -Constants.gravity})
    @debug_ctx = level.debug_ctx
    @debug_ctx.lineWidth = 0.03 # thickness of debug draw lines

    # Double default precision between wheel and ground (to avoid seing space between them)
    Settings.linearSlop = 0.0025

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
  # Without this cap, a slow world.step() (huge level, slow device, tab
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

      try
        @world.step(1.0/Constants.fps, 10, 10)
      catch e
        console.error("XMoto warning: #{e.message}")

      @level.input.space = false # Space can't stay pressed (used for `.move` and `.add_step`)

      if @level.need_to_restart
        @restart()
        @level.need_to_restart = false

  create_polygon: (vertices, name, density = 1.0, restitution = 0.5, friction = 1.0, group_index = -2) ->
    shape = new Polygon(Physics.create_shape(vertices))

    body = @world.createBody({
      type:     'static'
      position: {x: 0, y: 0}
      userData: {name: name}
    })

    body.createFixture(shape, {
      density:          density
      restitution:      restitution
      friction:         friction
      filterGroupIndex: group_index
    })

  create_lines: (block, name, density = 1.0, restitution = 0.5, friction = 1.0, group_index = -2) ->
    return if !block.vertices.length

    # Some levels contain consecutive (near-)duplicate vertices, which would
    # produce a zero-length edge and fail Chain's assertion.
    vertices = Physics.dedupe_vertices(block.vertices)

    # One closed Chain for the whole block outline. Chain automatically wires
    # up ghost vertices between adjacent segments, which suppresses spurious
    # internal-edge collisions that a set of disconnected segments would cause.
    shape = new Chain(vertices, true)

    body = @world.createBody({
      type:     'static'
      position: {x: block.position.x, y: block.position.y}
      userData: {name: name}
    })

    body.createFixture(shape, {
      density:          density
      restitution:      restitution
      friction:         friction
      filterGroupIndex: group_index
    })

  # Remove consecutive (cyclic) vertices that are too close (or the same).
  # It will avoid zero-length edges that would crash Chain's construction.
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

  # Dedupes and optionally mirrors (X-flip + winding reversal) a set of
  # vertices, returning plain {x,y} points ready for `new Polygon(...)`.
  @create_shape: (vertices, mirror = false) ->
    vertices = Physics.dedupe_vertices(vertices)
    result   = []

    if mirror == false
      for vertex in vertices
        result.push({x: vertex.x, y: vertex.y})
    else
      for vertex in vertices
        result.unshift({x: -vertex.x, y: vertex.y})

    result

  # Custom debug draw (planck has no bundled equivalent to Box2dWeb's
  # b2DebugDraw/DrawDebugData — its testbed renderer is a separate,
  # stage-js-based bundle not worth pulling in for this hidden debug canvas).
  # Draws directly onto @debug_ctx, which the caller (Camera#update) has
  # already translated/scaled to camera space in world (Y-up) coordinates.
  BODY_COLORS:
    inactive:        'rgba(127,127,76,1)'
    static:          'rgba(127,229,127,1)'
    kinematic:       'rgba(127,127,229,1)'
    sleeping:        'rgba(153,153,153,1)'
    awake:           'rgba(229,178,178,1)'
  JOINT_COLOR: 'rgba(127,204,204,1)'

  draw_debug: ->
    ctx = @debug_ctx
    ctx.clearRect(-1e6, -1e6, 2e6, 2e6)

    body = @world.getBodyList()
    while body
      @draw_debug_body(body, ctx)
      body = body.getNext()

    joint = @world.getJointList()
    while joint
      @draw_debug_joint(joint, ctx)
      joint = joint.getNext()

  draw_debug_body: (body, ctx) ->
    color =
      if      !body.isActive()          then @BODY_COLORS.inactive
      else if body.getType() == 'static'    then @BODY_COLORS.static
      else if body.getType() == 'kinematic' then @BODY_COLORS.kinematic
      else if !body.isAwake()           then @BODY_COLORS.sleeping
      else                                    @BODY_COLORS.awake

    fixture = body.getFixtureList()
    while fixture
      @draw_debug_shape(fixture.getShape(), body, color, ctx)
      fixture = fixture.getNext()

  draw_debug_shape: (shape, body, color, ctx) ->
    switch shape.getType()
      when 'circle'
        center = body.getWorldPoint(shape.m_p)
        ctx.beginPath()
        ctx.strokeStyle = color
        ctx.arc(center.x, center.y, shape.m_radius, 0, 2*Math.PI)
        ctx.closePath()
        ctx.stroke()
      when 'polygon'
        @draw_debug_polyline(shape.m_vertices.map((v) -> body.getWorldPoint(v)), true, color, ctx)
      when 'chain'
        @draw_debug_polyline(shape.m_vertices.map((v) -> body.getWorldPoint(v)), shape.isLoop(), color, ctx)

  draw_debug_polyline: (points, close, color, ctx) ->
    return if !points.length

    ctx.beginPath()
    ctx.strokeStyle = color
    ctx.moveTo(points[0].x, points[0].y)
    ctx.lineTo(point.x, point.y) for point in points[1..]
    ctx.closePath() if close
    ctx.stroke()

  draw_debug_joint: (joint, ctx) ->
    anchor_a = joint.getAnchorA()
    anchor_b = joint.getAnchorB()

    ctx.strokeStyle = @JOINT_COLOR

    ctx.beginPath()
    ctx.moveTo(joint.getBodyA().getPosition().x, joint.getBodyA().getPosition().y)
    ctx.lineTo(anchor_a.x, anchor_a.y)
    ctx.stroke()

    ctx.beginPath()
    ctx.moveTo(anchor_a.x, anchor_a.y)
    ctx.lineTo(anchor_b.x, anchor_b.y)
    ctx.stroke()

    ctx.beginPath()
    ctx.moveTo(anchor_b.x, anchor_b.y)
    ctx.lineTo(joint.getBodyB().getPosition().x, joint.getBodyB().getPosition().y)
    ctx.stroke()
