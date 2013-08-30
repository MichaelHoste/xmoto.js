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
b2DebugDraw     = Box2D.Dynamics.b2DebugDraw
b2MouseJointDef = Box2D.Dynamics.Joints.b2MouseJointDef

class Physics

  constructor: (level) ->
    @scale = 30
    @level = level
    @world = new b2World(new b2Vec2(0, -10), true) # gravity vector, and doSleep

    context = @level.ctx

    # debug initialization
    debugDraw = new b2DebugDraw()
    debugDraw.SetSprite(context)    # context
    debugDraw.SetFillAlpha(0.3)     # transparency
    debugDraw.SetLineThickness(1.0) # thickness of line
    debugDraw.SetDrawScale(@scale)    # scale

    # Assign debug to world
    debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit)
    @world.SetDebugDraw(debugDraw)

    @world

  createBody: (type, x, y, dimensions, fixed, userData) ->
    # by default, static object
    fixed = true if typeof(fixed) == 'undefined'

    # Create fixture
    fixDef = new b2FixtureDef()
    fixDef.userData = userData

    # draw the object
    switch (type)
      when 'box'
        fixDef.shape = new b2PolygonShape()
        fixDef.shape.SetAsBox(dimensions.width / @scale, dimensions.height / @scale)
      when 'ball'
        fixDef.shape = new b2CircleShape(dimensions.radius / @scale)

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = x / @scale
    bodyDef.position.y = y / @scale

    if fixed
      bodyDef.type = b2Body.b2_staticBody
    else
      bodyDef.type = b2Body.b2_dynamicBody
      fixDef.density     = 1.0
      fixDef.restitution = 0.5
    fixDef.friction    = 1.0

    # Assign fixture to body and add body to 2D world
    @world.CreateBody(bodyDef).CreateFixture(fixDef)

  # Create "box" object
  createBox: (x, y, width, height, fixed, userData) ->
    dimensions =
      width:  width
      height: height

    this.createBody('box', x, y, dimensions, fixed, userData)

  createTriangle: (vertices, fixed, userData) ->
    # by default, static object
    fixed = true if typeof(fixed) == 'undefined'

    # Create fixture
    fixDef = new b2FixtureDef()
    fixDef.userData = userData

    fixDef.shape = new b2PolygonShape()

    fixDef.shape.SetAsArray( [
      new b2Vec2(vertices[0].x / @scale, vertices[0].y / @scale),
      new b2Vec2(vertices[1].x / @scale, vertices[1].y / @scale),
      new b2Vec2(vertices[2].x / @scale, vertices[2].y / @scale) ])

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = 0
    bodyDef.position.y = 0

    if fixed
      bodyDef.type = b2Body.b2_staticBody
    else
      bodyDef.type = b2Body.b2_dynamicBody
      fixDef.density     = 1.0
      fixDef.restitution = 0.5

    # Assign fixture to body and add body to 2D world
    @world.CreateBody(bodyDef).CreateFixture(fixDef)
