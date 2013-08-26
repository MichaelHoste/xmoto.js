$ ->
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

  class window.Box2dUtils

    constructor: (scale) ->
      this.SCALE = scale # Définir l'échelle

    # Create the 2d world
    # @param context 2D context
    # @return b2World
    createWorld: (context) ->
      world = new b2World(new b2Vec2(0, -10), true) # gravity vector, and doSleep

      # debug initialization
      debugDraw = new b2DebugDraw()
      debugDraw.SetSprite(context)    # context
      debugDraw.SetFillAlpha(0.3)     # transparency
      debugDraw.SetLineThickness(1.0) # thickness of line
      debugDraw.SetDrawScale(this.SCALE)    # scale

      # Assign debug to world
      debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit)
      world.SetDebugDraw(debugDraw)

      world

    # Create an object
    # @param type object type (string)
    # @param b2World box2D world
    # @param x x position of object
    # @param y y position of object
    # @param dimensions dimensions of object
    # @param fixed static (true) or dynamic (false)
    # @param userData custom values
    # @return object in its 2D world
    createBody: (type, world, x, y, dimensions, fixed, userData) ->
      # by default, static object
      fixed = true if typeof(fixed) == 'undefined'

      # Create fixture
      fixDef = new b2FixtureDef()
      fixDef.userData = userData

      # draw the object
      switch (type)
        when 'box'
          fixDef.shape = new b2PolygonShape()
          fixDef.shape.SetAsBox(dimensions.width/this.SCALE, dimensions.height/this.SCALE)
        when 'ball'
          fixDef.shape = new b2CircleShape(dimensions.radius/this.SCALE)

      # Create body
      bodyDef = new b2BodyDef()

      # Assign body position
      bodyDef.position.x = x/this.SCALE
      bodyDef.position.y = y/this.SCALE

      if fixed
        bodyDef.type = b2Body.b2_staticBody
      else
        bodyDef.type = b2Body.b2_dynamicBody
        fixDef.density     = 1.0
        fixDef.restitution = 0.5

      # Assign fixture to body and add body to 2D world
      world.CreateBody(bodyDef).CreateFixture(fixDef)

    # Create "box" object
    createBox: (world, x, y, width, height, fixed, userData) ->
      dimensions =
        width:  width
        height: height

      this.createBody('box', world, x, y, dimensions, fixed, userData)

     # Create "ball" object
    createBall: (world, x, y, radius, fixed, userData) ->
      dimensions =
        radius: radius

      this.createBody('ball', world, x, y, dimensions, fixed, userData)

    addTriangle: (world) ->
      bodyDef = new b2BodyDef
      fixDef = new b2FixtureDef
      fixDef.density = Math.random()
      fixDef.friction = Math.random()
      fixDef.restitution = 0.2

      bodyDef.type = b2Body.b2_dynamicBody
      fixDef.shape = new b2PolygonShape
      scale = Math.random() * 60;
      fixDef.shape.SetAsArray([
        new b2Vec2(scale*0.866 , scale*0.5),
        new b2Vec2(scale*-0.866, scale*0.5),
        new b2Vec2(0, scale*-1) ])

      bodyDef.position.x = 0#(1000-scale*2)*Math.random()+scale*2
      bodyDef.position.y = 0#400 - (scale*Math.random() +scale)
      world.CreateBody(bodyDef).CreateFixture(fixDef)

    createTriangle: (world, vertices, fixed, userData) ->
      # by default, static object
      fixed = true if typeof(fixed) == 'undefined'

      # Create fixture
      fixDef = new b2FixtureDef()
      fixDef.userData = userData

      fixDef.shape = new b2PolygonShape()

      fixDef.shape.SetAsArray( [
        new b2Vec2(vertices[0].x/this.SCALE, vertices[0].y/this.SCALE),
        new b2Vec2(vertices[1].x/this.SCALE, vertices[1].y/this.SCALE),
        new b2Vec2(vertices[2].x/this.SCALE, vertices[2].y/this.SCALE) ])

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
      world.CreateBody(bodyDef).CreateFixture(fixDef)
