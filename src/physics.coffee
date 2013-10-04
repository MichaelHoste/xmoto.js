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
b2Settings      = Box2D.Common.b2Settings

class Physics

  constructor: (level) ->
    @scale = level.scale.x
    @level = level
    @world = new b2World(new b2Vec2(0, -10), true) # gravity vector, and doSleep

    # Double default precision between wheel and ground
    b2Settings.b2_linearSlop = 0.0025;

    context = @level.ctx

    # debug initialization
    debugDraw = new b2DebugDraw()
    debugDraw.SetSprite(context)    # context
    debugDraw.SetFillAlpha(0.3)     # transparency
    debugDraw.SetLineThickness(1.0) # thickness of line
    #debugDraw.SetDrawScale(1)      # scale

    # Assign debug to world
    debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit)
    @world.SetDebugDraw(debugDraw)

    @world

  createPolygon: (vertices) ->
    # Create fixture
    fixDef = new b2FixtureDef()

    fixDef.shape = new b2PolygonShape()
    fixDef.density     = 1.0
    fixDef.restitution = 0.5
    fixDef.friction    = 1.0

    # Create polygon
    b2vertices = []
    for vertex in vertices
      b2vertices.push(new b2Vec2(vertex.x, vertex.y))
    fixDef.shape.SetAsArray(b2vertices)

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = 0
    bodyDef.position.y = 0

    bodyDef.type = b2Body.b2_staticBody

    # Assign fixture to body and add body to 2D world
    @world.CreateBody(bodyDef).CreateFixture(fixDef)

  @flip_collisions: (body) ->
    vertices = body.GetFixtureList().GetShape().GetVertices()
    new_vertices = [ new b2Vec2(-vertices[3].x, vertices[3].y),
                     new b2Vec2(-vertices[2].x, vertices[2].y),
                     new b2Vec2(-vertices[1].x, vertices[1].y),
                     new b2Vec2(-vertices[0].x, vertices[0].y) ]
    body.GetFixtureList().GetShape().SetAsArray(new_vertices)
