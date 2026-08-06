# Custom debug draw (Planck.js has no b2DebugDraw/DrawDebugData like Box2Dweb)
# Draws directly onto @context canvas

class PhysicsDrawingService

  BACKGROUND_COLOR = '#222229'
  FILL_ALPHA       = 0.45

  JOINT_COLOR = '127,204,204'

  BODY_COLORS =
    inactive:  '127,127,76'
    static:    '127,229,127'
    kinematic: '127,127,229'
    sleeping:  '153,153,153'
    awake:     '229,178,178'

  constructor: (ctx, world) ->
    @ctx   = ctx
    @world = world

  draw: ->
    @ctx.fillStyle = BACKGROUND_COLOR
    @ctx.fillRect(-1e6, -1e6, 2e6, 2e6)

    body = @world.getBodyList()

    while body
      @draw_body(body)
      body = body.getNext()

    joint = @world.getJointList()

    while joint
      @draw_joint(joint)
      joint = joint.getNext()

  draw_body: (body) ->
    if !body.isActive()
      color = BODY_COLORS.inactive
    else if body.getType() == 'static'
      color = BODY_COLORS.static
    else if body.getType() == 'kinematic'
      color = BODY_COLORS.kinematic
    else if !body.isAwake()
      color = BODY_COLORS.sleeping
    else
      color = BODY_COLORS.awake

    fixture = body.getFixtureList()

    while fixture
      @draw_shape(fixture.getShape(), body, color)
      fixture = fixture.getNext()

  draw_shape: (shape, body, color) ->
    switch shape.getType()
      when 'circle'
        center = body.getWorldPoint(shape.m_p)
        edge   = body.getWorldPoint({x: shape.m_p.x + shape.m_radius, y: shape.m_p.y})

        # Circle
        @ctx.beginPath()
        @ctx.fillStyle   = "rgba(#{color},#{FILL_ALPHA})"
        @ctx.strokeStyle = "rgba(#{color},1)"
        @ctx.arc(center.x, center.y, shape.m_radius, 0, 2*Math.PI)
        @ctx.closePath()
        @ctx.fill()
        @ctx.stroke()

        # Line from center to edge along the body x axis (to see rotation)
        @ctx.beginPath()
        @ctx.moveTo(center.x, center.y)
        @ctx.lineTo(edge.x, edge.y)
        @ctx.stroke()
      when 'polygon'
        @draw_polyline(shape.m_vertices.map((v) -> body.getWorldPoint(v)), true, color)
      when 'chain'
        @draw_polyline(shape.m_vertices.map((v) -> body.getWorldPoint(v)), shape.isLoop(), color)
      when 'edge'
        vertices = [shape.m_vertex1, shape.m_vertex2]
        @draw_polyline(vertices.map((v) -> body.getWorldPoint(v)), false, color)
      else
        console.error("XMoto warning: shapes of type \"#{shape.getType()}\" cannot be rendered on the debug canvas for physics.")

  draw_polyline: (points, close, color) ->
    return if !points.length

    @ctx.beginPath()
    @ctx.fillStyle   = "rgba(#{color},#{FILL_ALPHA})"
    @ctx.strokeStyle = "rgba(#{color},1)"
    @ctx.moveTo(points[0].x, points[0].y)
    @ctx.lineTo(point.x, point.y) for point in points[1..]
    @ctx.closePath() if close
    @ctx.fill() if close
    @ctx.stroke()

  draw_joint: (joint) ->
    anchor_a = joint.getAnchorA()
    anchor_b = joint.getAnchorB()

    @ctx.strokeStyle = "rgba(#{JOINT_COLOR},1)"

    @ctx.beginPath()
    @ctx.moveTo(joint.getBodyA().getPosition().x, joint.getBodyA().getPosition().y)
    @ctx.lineTo(anchor_a.x, anchor_a.y)
    @ctx.stroke()

    @ctx.beginPath()
    @ctx.moveTo(anchor_a.x, anchor_a.y)
    @ctx.lineTo(anchor_b.x, anchor_b.y)
    @ctx.stroke()

    @ctx.beginPath()
    @ctx.moveTo(anchor_b.x, anchor_b.y)
    @ctx.lineTo(joint.getBodyB().getPosition().x, joint.getBodyB().getPosition().y)
    @ctx.stroke()
