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
b2RevoluteJointDef  = Box2D.Dynamics.Joints.b2RevoluteJointDef

class Moto

  constructor: (level) ->
    @level  = level
    @assets = level.assets

  display: ->
    @display_wheel(@left_wheel)
    @display_wheel(@right_wheel)
    @display_left_axle()
    @display_right_axle()
    @display_body()

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
    @bike_body    = @create_bike_body(@player_start.x, @player_start.y + 1.0)

    @left_wheel   = @create_wheel(@player_start.x - 0.7, @player_start.y + 0.48)
    @right_wheel  = @create_wheel(@player_start.x + 0.7, @player_start.y + 0.48)

    @left_axle    = @create_left_axle( @player_start.x, @player_start.y + 1.0)
    @right_axle   = @create_right_axle(@player_start.x, @player_start.y + 1.0)

    @left_revolute_joint  = @create_left_revolute_joint()
    @left_prismatic_joint = @create_left_prismatic_joint()

    @right_revolute_joint  = @create_right_revolute_joint()
    @right_prismatic_joint = @create_right_prismatic_joint()

  position: ->
    position = @bike_body.GetPosition()
    { x: position.x, y: position.y }

  create_bike_body: (x, y)  ->
    # Create fixture
    fixDef = new b2FixtureDef()

    fixDef.shape       = new b2PolygonShape()
    fixDef.density     = 1.0
    fixDef.restitution = 0.5
    fixDef.friction    = 1.0
    fixDef.filter.groupIndex = -1

    b2vertices = [ new b2Vec2(  0.6, -0.3),
                   new b2Vec2(  0.6,  0.4),
                   new b2Vec2( -0.7,  0.4),
                   new b2Vec2( -0.7, -0.3) ]

    fixDef.shape.SetAsArray(b2vertices)

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = x
    bodyDef.position.y = y

    bodyDef.type = b2Body.b2_dynamicBody

    # Assign fixture to body and add body to 2D world
    body = @level.world.CreateBody(bodyDef)
    body.CreateFixture(fixDef)

    body

  create_wheel: (x, y) ->
    # Create fixture
    fixDef = new b2FixtureDef()

    fixDef.shape = new b2CircleShape(0.35)
    fixDef.density     = 1.0
    fixDef.restitution = 0.5
    fixDef.friction    = 1.0
    fixDef.filter.groupIndex = -1

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = x
    bodyDef.position.y = y

    bodyDef.type = b2Body.b2_dynamicBody

    # Assign fixture to body and add body to 2D world
    wheel = @level.world.CreateBody(bodyDef)
    wheel.CreateFixture(fixDef)

    wheel

  create_left_axle: (x, y) ->
    # Create fixture
    fixDef = new b2FixtureDef()

    fixDef.shape       = new b2PolygonShape()
    fixDef.density     = 1.0
    fixDef.restitution = 0.5
    fixDef.friction    = 1.0
    fixDef.filter.groupIndex = -1

    b2vertices = [ new b2Vec2( -0.10,  -0.30),
                   new b2Vec2( -0.25,  -0.30),
                   new b2Vec2( -0.80,  -0.58),
                   new b2Vec2( -0.65,  -0.58) ]

    fixDef.shape.SetAsArray(b2vertices)

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = x
    bodyDef.position.y = y

    bodyDef.type = b2Body.b2_dynamicBody

    # Assign fixture to body and add body to 2D world
    body = @level.world.CreateBody(bodyDef)
    body.CreateFixture(fixDef)

    body

  create_right_axle: (x, y) ->
    # Create fixture
    fixDef = new b2FixtureDef()

    fixDef.shape       = new b2PolygonShape()
    fixDef.density     = 1.0
    fixDef.restitution = 0.5
    fixDef.friction    = 1.0
    fixDef.filter.groupIndex = -1

    b2vertices = [ new b2Vec2( 0.58,  -0.02),
                   new b2Vec2( 0.48,  -0.02),
                   new b2Vec2( 0.66,  -0.58),
                   new b2Vec2( 0.76,  -0.58) ]

    fixDef.shape.SetAsArray(b2vertices)

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = x
    bodyDef.position.y = y

    bodyDef.type = b2Body.b2_dynamicBody

    # Assign fixture to body and add body to 2D world
    body = @level.world.CreateBody(bodyDef)
    body.CreateFixture(fixDef)

    body

  create_left_revolute_joint: ->
    jointDef = new b2RevoluteJointDef()
    jointDef.Initialize(@left_axle, @left_wheel, @left_wheel.GetWorldCenter())
    @level.world.CreateJoint(jointDef)

  create_right_revolute_joint: ->
    jointDef = new b2RevoluteJointDef()
    jointDef.Initialize(@right_axle, @right_wheel, @right_wheel.GetWorldCenter())
    @level.world.CreateJoint(jointDef)

  create_left_prismatic_joint: ->
    jointDef = new b2PrismaticJointDef()
    jointDef.Initialize(@bike_body, @left_axle, @left_axle.GetWorldCenter(), new b2Vec2(0.1, 1) )
    jointDef.enableLimit = true
    jointDef.lowerTranslation = -0.10
    jointDef.upperTranslation = 0.20
    jointDef.enableMotor = true
    jointDef.collideConnected = false
    @level.world.CreateJoint(jointDef)

  create_right_prismatic_joint: ->
    jointDef = new b2PrismaticJointDef()
    jointDef.Initialize(@bike_body, @right_axle, @right_axle.GetWorldCenter(), new b2Vec2(-0.1, 1) )
    jointDef.enableLimit = true
    jointDef.lowerTranslation = -0.0
    jointDef.upperTranslation = 0.20
    jointDef.enableMotor = true
    jointDef.collideConnected = false
    @level.world.CreateJoint(jointDef)

  display_wheel: (wheel) ->
    # Position
    position = wheel.GetPosition()

    # Radius
    radius = wheel.GetFixtureList().GetShape().m_radius

    # Angle
    angle = wheel.GetAngle()

    # Draw texture
    @level.ctx.save()
    @level.ctx.translate(position.x, position.y)
    @level.ctx.rotate(angle)

    @level.ctx.drawImage(
      @assets.get('playerbikerwheel'), # texture
      -radius, # x
      -radius, # y
       radius*2, # size-x
       radius*2  # size-y
    )

    @level.ctx.restore()

  display_body: ->
    # Position
    position = @position()

    # Angle
    angle = @bike_body.GetAngle()

    # Draw texture
    @level.ctx.save()
    @level.ctx.translate(position.x, position.y)
    @level.ctx.scale(1, -1)
    @level.ctx.rotate(-angle)

    @level.ctx.drawImage(
      @assets.get('playerbikerbody'), # texture
      -1.0,   # x
      -0.5,   # y
       2.0, # size-x
       1.0  # size-y
    )

    @level.ctx.restore()

  display_left_axle: ->
    axle_thickness = 0.09

    # Position
    left_wheel_position = @left_wheel.GetPosition()
    left_wheel_position =
      x: left_wheel_position.x - axle_thickness/2.0
      y: left_wheel_position.y - axle_thickness/2.0 + 0.02

    # Position relative to center of body
    left_axle_position =
      x: - 0.17
      y: - 0.30

    # Adjusted position depending of rotation of body
    left_axle_adjusted_position = rotate_point(left_axle_position, @bike_body.GetAngle(), @position())

    # Distance
    distance = distance_between_points(left_wheel_position, left_axle_adjusted_position)

    # Angle
    angle = angle_between_points(left_axle_adjusted_position, left_wheel_position) + Math.PI/2

    # Draw texture
    @level.ctx.save()
    @level.ctx.translate(left_wheel_position.x, left_wheel_position.y)
    @level.ctx.scale(1, -1)
    @level.ctx.rotate(-angle)

    @level.ctx.drawImage(
      @assets.get('front1'), # texture
      0.0,               # x
      -axle_thickness/2, # y
      distance,          # size-x
      axle_thickness     # size-y
    )

    @level.ctx.restore()

  display_right_axle: ->
    axle_thickness = 0.09

    # Position
    right_wheel_position = @right_wheel.GetPosition()
    right_wheel_position =
      x: right_wheel_position.x + axle_thickness/2.0 - 0.03
      y: right_wheel_position.y - axle_thickness/2.0

    # Position relative to center of body
    right_axle_position =
      x: 0.54
      y: 0.025

    # Adjusted position depending of rotation of body
    right_axle_adjusted_position = rotate_point(right_axle_position, @bike_body.GetAngle(), @position())

    # Distance
    distance = distance_between_points(right_wheel_position, right_axle_adjusted_position)

    # Angle
    angle = angle_between_points(right_axle_adjusted_position, right_wheel_position) + Math.PI/2

    # Draw texture
    @level.ctx.save()
    @level.ctx.translate(right_wheel_position.x, right_wheel_position.y)
    @level.ctx.scale(1, -1)
    @level.ctx.rotate(-angle)

    @level.ctx.drawImage(
      @assets.get('front1'), # texture
      0.0,               # x
      -axle_thickness/2, # y
      distance,          # size-x
      axle_thickness     # size-y
    )

    @level.ctx.restore()

distance_between_points = (point1, point2) ->
  a = Math.pow(point1.x - point2.x, 2)
  b = Math.pow(point1.y - point2.y, 2)
  Math.sqrt(a+b)

angle_between_points = (point1, point2) ->
  adj = point2.x - point1.x
  opp = point2.y - point1.y

  angle = Math.abs(Math.atan(opp/adj) * 180/Math.PI)

  if adj > 0 && opp < 0
    angle = 90 - angle
  else if adj >= 0 && opp >= 0
    angle += 90
  else if adj < 0 && opp >= 0
    angle = 180 + (90 - angle)
  else
    angle += 270

  angle * Math.PI / 180.0 # radians

# Rotate point from angle around axe
rotate_point = (point, angle, rotation_axe) ->
  new_point =
    x: rotation_axe.x + point.x * Math.cos(angle) - point.y * Math.sin(angle)
    y: rotation_axe.y + point.x * Math.sin(angle) + point.y * Math.cos(angle)



