b2World             = Box2D.Dynamics.b2World
b2Vec2              = Box2D.Common.Math.b2Vec2
b2AABB              = Box2D.Collision.b2AABB
b2BodyDef           = Box2D.Dynamics.b2BodyDef
b2Body              = Box2D.Dynamics.b2Body
b2FixtureDef        = Box2D.Dynamics.b2FixtureDef
b2Fixture           = Box2D.Dynamics.b2Fixture
b2MassData          = Box2D.Collision.Shapes.b2MassData
b2PolygonShape      = Box2D.Collision.Shapes.b2PolygonShape
b2CircleShape       = Box2D.Collision.Shapes.b2CircleShape
b2DebugDraw         = Box2D.Dynamics.b2DebugDraw
b2MouseJointDef     = Box2D.Dynamics.Joints.b2MouseJointDef
b2PrismaticJointDef = Box2D.Dynamics.Joints.b2PrismaticJointDef


class Moto

  constructor: (level) ->
    @level  = level
    @assets = level.assets
    @scale  = @level.physics.scale

  display: ->
    @display_body()
    @display_wheel(@left_wheel)
    @display_wheel(@right_wheel)

  init: ->
    # Assets
    textures = [ 'front1', 'lowerarm1', 'lowerleg1', 'playerbikerbody',
                 'playerbikerwheel', 'playerlowerarm', 'playerlowerleg',
                 'playertorso', 'playerupperarm', 'playerupperleg', 'rear1',
                 'upperarm1', 'upperleg1' ]
    for texture in textures
      @assets.moto.push(texture)

    # Creation of moto parts
    @player_start = @level.entities.player_start
    @bike_body    = @create_bike_body()
    @left_wheel   = @create_wheel(@player_start.x - 0.7, @player_start.y + 0.45)
    @right_wheel  = @create_wheel(@player_start.x + 0.7, @player_start.y + 0.45)
    #@create_joints()

  create_bike_body: ->
    # Create fixture
    fixDef = new b2FixtureDef()

    # Create the object
    fixDef.shape       = new b2PolygonShape()
    fixDef.density     = 1.0
    fixDef.restitution = 0.5
    fixDef.friction    = 1.0
    fixDef.filter.groupIndex = -1

    b2vertices = [ new b2Vec2(  1 / @scale, -0.5 / @scale),
                   new b2Vec2(  1 / @scale,  0.5 / @scale),
                   new b2Vec2( -1 / @scale,  0.5 / @scale),
                   new b2Vec2( -1 / @scale, -0.5 / @scale) ]

    fixDef.shape.SetAsArray(b2vertices)

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = @player_start.x         / @scale
    bodyDef.position.y = (@player_start.y + 1.0) / @scale

    #bodyDef.type = b2Body.b2_dynamicBody
    bodyDef.type = b2Body.b2_staticBody

    # Assign fixture to body and add body to 2D world
    body = @level.world.CreateBody(bodyDef)
    body.CreateFixture(fixDef)

    body

  create_wheel: (x, y) ->
    # Create fixture
    fixDef = new b2FixtureDef()

    # Create the object
    fixDef.shape = new b2CircleShape(0.35 / @scale)

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = x / @scale
    bodyDef.position.y = y / @scale

    bodyDef.type = b2Body.b2_staticBody
    #bodyDef.type = b2Body.b2_dynamicBody
    fixDef.density     = 1.0
    fixDef.restitution = 0.5
    fixDef.friction    = 1.0
    fixDef.filter.groupIndex = -1

    # Assign fixture to body and add body to 2D world
    wheel = @level.world.CreateBody(bodyDef)
    wheel.CreateFixture(fixDef)

    wheel

  create_joints: ->
    jointDef = new b2PrismaticJointDef()
    jointDef.Initialize(@bike_body, @left_wheel, @bike_body.GetWorldCenter(), { x: -0.15, y: -0.15 } )
    jointDef.lowerTranslation = -0.002
    jointDef.upperTranslation =  0.002
    jointDef.enableLimit = true
    #jointDef.maxMotorForce = 1.0
    #jointDef.motorSpeed = 0.0
    #jointDef.enableMotor = true
    @level.world.CreateJoint(jointDef)

  display_wheel: (wheel) ->
    # Position
    position = wheel.GetPosition()
    scaled_position =
      x: position.x*@scale
      y: position.y*@scale

    # Radius
    radius = wheel.GetFixtureList().GetShape().m_radius
    scaled_radius = radius*@scale

    # Angle
    angle = wheel.GetAngle()

    # Draw texture
    @level.ctx.save()
    @level.ctx.translate(scaled_position.x, scaled_position.y)
    @level.ctx.rotate(angle)

    @level.ctx.drawImage(
      @assets.get('playerbikerwheel'), # texture
      -scaled_radius,   # x
       scaled_radius,   # y
       scaled_radius*2, # size-x
      -scaled_radius*2  # size-y
    )

    @level.ctx.restore()

  display_body: ->
    # Position
    position = @bike_body.GetPosition()
    scaled_position =
      x: position.x*@scale
      y: position.y*@scale

    # Angle
    angle = @bike_body.GetAngle()

    # Draw texture
    @level.ctx.save()
    @level.ctx.translate(scaled_position.x, scaled_position.y)
    @level.ctx.scale(1, -1)
    @level.ctx.rotate(-angle)

    @level.ctx.drawImage(
      @assets.get('playerbikerbody'), # texture
      -1.0,   # x
       0.5,   # y
       2.0, # size-x
      -1.0  # size-y
    )

    @level.ctx.restore()
