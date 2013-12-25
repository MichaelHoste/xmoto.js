b2Vec2              = Box2D.Common.Math.b2Vec2
b2BodyDef           = Box2D.Dynamics.b2BodyDef
b2Body              = Box2D.Dynamics.b2Body
b2FixtureDef        = Box2D.Dynamics.b2FixtureDef
b2Fixture           = Box2D.Dynamics.b2Fixture
b2PolygonShape      = Box2D.Collision.Shapes.b2PolygonShape
b2CircleShape       = Box2D.Collision.Shapes.b2CircleShape
b2PrismaticJointDef = Box2D.Dynamics.Joints.b2PrismaticJointDef
b2RevoluteJointDef  = Box2D.Dynamics.Joints.b2RevoluteJointDef

class Moto

  constructor: (level, mirror = false) ->
    @level    = level
    @assets   = level.assets
    @mirror   = if mirror then -1 else 1
    @rider    = new Rider(level, this)
    @dead     = false

  destroy: ->
    world = @level.world

    @rider.destroy()

    world.DestroyBody(@body)
    world.DestroyBody(@left_wheel)
    world.DestroyBody(@right_wheel)
    world.DestroyBody(@left_axle)
    world.DestroyBody(@right_axle)

    world.DestroyJoint(@left_revolute_joint)
    world.DestroyJoint(@left_prismatic_joint)
    world.DestroyJoint(@right_revolute_joint)
    world.DestroyJoint(@right_prismatic_joint)

  display: ->
    @display_wheel(@left_wheel)
    @display_wheel(@right_wheel)
    @display_left_axle()
    @display_right_axle()
    @display_body()
    @rider.display()

  init: ->
    # Assets
    parts = [ Constants.body, Constants.wheels, Constants.left_axle, Constants.right_axle ]
    for part in parts
      @assets.moto.push(part.texture)

    # Creation of moto parts
    @player_start = @level.entities.player_start

    @body         = @create_body(@player_start.x + @mirror * Constants.body.position.x,
                                 @player_start.y + Constants.body.position.y)

    @left_wheel   = @create_wheel(@player_start.x - @mirror * Constants.wheels.position.x,
                                  @player_start.y + Constants.wheels.position.y)

    @right_wheel  = @create_wheel(@player_start.x + @mirror * Constants.wheels.position.x,
                                  @player_start.y + Constants.wheels.position.y)

    @left_axle    = @create_left_axle( @player_start.x + @mirror * Constants.left_axle.position.x,
                                       @player_start.y + Constants.left_axle.position.y)

    @right_axle   = @create_right_axle(@player_start.x + @mirror * Constants.right_axle.position.x,
                                       @player_start.y + Constants.right_axle.position.y)

    @left_revolute_joint  = @create_left_revolute_joint()
    @left_prismatic_joint = @create_left_prismatic_joint()

    @right_revolute_joint  = @create_right_revolute_joint()
    @right_prismatic_joint = @create_right_prismatic_joint()

    @rider.init()

  position: ->
    @body.GetPosition()

  create_body: (x, y)  ->
    # Create fixture
    fixDef = new b2FixtureDef()

    fixDef.shape       = new b2PolygonShape()
    fixDef.density     = Constants.body.density
    fixDef.restitution = Constants.body.restitution
    fixDef.friction    = Constants.body.friction
    fixDef.isSensor    = !Constants.body.collisions
    fixDef.filter.groupIndex = -1

    Physics.create_shape(fixDef, Constants.body.shape, @mirror == -1)

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = x
    bodyDef.position.y = y

    bodyDef.userData =
      name: 'moto'

    bodyDef.type = b2Body.b2_dynamicBody

    # Assign fixture to body and add body to 2D world
    body = @level.world.CreateBody(bodyDef)
    body.CreateFixture(fixDef)

    body

  create_wheel: (x, y) ->
    # Create fixture
    fixDef = new b2FixtureDef()

    fixDef.shape = new b2CircleShape(Constants.wheels.radius)
    fixDef.density     = Constants.wheels.density
    fixDef.restitution = Constants.wheels.restitution
    fixDef.friction    = Constants.wheels.friction
    fixDef.isSensor    = !Constants.wheels.collisions
    fixDef.filter.groupIndex = -1

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = x
    bodyDef.position.y = y

    bodyDef.userData =
      name: 'moto'

    bodyDef.type = b2Body.b2_dynamicBody

    # Assign fixture to body and add body to 2D world
    wheel = @level.world.CreateBody(bodyDef)
    wheel.CreateFixture(fixDef)

    wheel

  create_left_axle: (x, y) ->
    # Create fixture
    fixDef = new b2FixtureDef()

    fixDef.shape       = new b2PolygonShape()
    fixDef.density     = Constants.left_axle.density
    fixDef.restitution = Constants.left_axle.restitution
    fixDef.friction    = Constants.left_axle.friction
    fixDef.isSensor    = !Constants.left_axle.collisions
    fixDef.filter.groupIndex = -1

    Physics.create_shape(fixDef, Constants.left_axle.shape, @mirror == -1)

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = x
    bodyDef.position.y = y

    bodyDef.userData =
      name: 'moto'

    bodyDef.type = b2Body.b2_dynamicBody

    # Assign fixture to body and add body to 2D world
    body = @level.world.CreateBody(bodyDef)
    body.CreateFixture(fixDef)

    body

  create_right_axle: (x, y) ->
    # Create fixture
    fixDef = new b2FixtureDef()

    fixDef.shape       = new b2PolygonShape()
    fixDef.density     = Constants.right_axle.density
    fixDef.restitution = Constants.right_axle.restitution
    fixDef.friction    = Constants.right_axle.friction
    fixDef.isSensor    = !Constants.right_axle.collisions
    fixDef.filter.groupIndex = -1

    Physics.create_shape(fixDef, Constants.right_axle.shape, @mirror == -1)

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = x
    bodyDef.position.y = y

    bodyDef.userData =
      name: 'moto'

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
    angle = Constants.left_suspension.angle
    jointDef.Initialize(@body, @left_axle, @left_axle.GetWorldCenter(), new b2Vec2(@mirror * angle.x, angle.y))
    jointDef.enableLimit      = true
    jointDef.lowerTranslation = Constants.left_suspension.lower_translation
    jointDef.upperTranslation = Constants.left_suspension.upper_translation
    jointDef.enableMotor      = true
    jointDef.collideConnected = false
    @level.world.CreateJoint(jointDef)

  create_right_prismatic_joint: ->
    jointDef = new b2PrismaticJointDef()
    angle = Constants.right_suspension.angle
    jointDef.Initialize(@body, @right_axle, @right_axle.GetWorldCenter(), new b2Vec2(@mirror * angle.x, angle.y))
    jointDef.enableLimit      = true
    jointDef.lowerTranslation = Constants.right_suspension.lower_translation
    jointDef.upperTranslation = Constants.right_suspension.upper_translation
    jointDef.enableMotor      = true
    jointDef.collideConnected = false
    @level.world.CreateJoint(jointDef)

  display_wheel: (wheel) ->
    # Get angle and position
    position = wheel.GetPosition()
    angle    = wheel.GetAngle()

    # Draw Texture
    @level.ctx.save()
    @level.ctx.translate(position.x, position.y)
    @level.ctx.rotate(angle)

    @level.ctx.drawImage(
      @assets.get(Constants.wheels.texture), # texture
      -Constants.wheels.radius,      # x
      -Constants.wheels.radius,      # y
       Constants.wheels.radius*2,    # size-x
       Constants.wheels.radius*2     # size-y
    )

    @level.ctx.restore()

  display_body: ->
    # Get angle and position
    position = @body.GetPosition()
    angle    = @body.GetAngle()

    # Draw texture
    @level.ctx.save()
    @level.ctx.translate(position.x, position.y)
    @level.ctx.scale(@mirror, -1)
    @level.ctx.rotate(@mirror*(-angle))

    @level.ctx.drawImage(
      @assets.get(Constants.body.texture), # texture
      -1.0, # x
      -0.5, # y
       2.0, # size-x
       1.0  # size-y
    )

    @level.ctx.restore()

  display_left_axle: ->
    axle_thickness = 0.09

    # Position
    wheel_position = @left_wheel.GetPosition()
    wheel_position =
      x: wheel_position.x - @mirror * axle_thickness/2.0
      y: wheel_position.y - 0.025

    # Position relative to center of body
    axle_position =
      x: -0.17 * @mirror
      y: -0.30

    # Adjusted position depending of rotation of body
    axle_adjusted_position = Math2D.rotate_point(axle_position, @body.GetAngle(), @body.GetPosition())

    # Distance
    distance = Math2D.distance_between_points(wheel_position, axle_adjusted_position)

    # Angle
    angle = Math2D.angle_between_points(axle_adjusted_position, wheel_position) + @mirror * Math.PI/2

    # Draw texture
    @level.ctx.save()
    @level.ctx.translate(wheel_position.x, wheel_position.y)
    @level.ctx.scale(@mirror, -1)
    @level.ctx.rotate(@mirror*(-angle))

    @level.ctx.drawImage(
      @assets.get(Constants.left_axle.texture), # texture
      0.0,               # x
      -axle_thickness/2, # y
      distance,          # size-x
      axle_thickness     # size-y
    )

    @level.ctx.restore()

  display_right_axle: ->
    axle_thickness = 0.07

    # Position
    wheel_position = @right_wheel.GetPosition()
    position =
      x: wheel_position.x + @mirror * axle_thickness/2.0 - @mirror * 0.03
      y: wheel_position.y - 0.045

    # Position relative to center of body
    axle_position =
      x: 0.52 * @mirror
      y: 0.025

    # Adjusted position depending of rotation of body
    axle_adjusted_position = Math2D.rotate_point(axle_position, @body.GetAngle(), @body.GetPosition())

    # Distance
    distance = Math2D.distance_between_points(wheel_position, axle_adjusted_position)

    # Angle
    angle = Math2D.angle_between_points(axle_adjusted_position, wheel_position) + @mirror * Math.PI/2

    # Draw texture
    @level.ctx.save()
    @level.ctx.translate(wheel_position.x, wheel_position.y)
    @level.ctx.scale(@mirror, -1)
    @level.ctx.rotate(@mirror*(-angle))

    @level.ctx.drawImage(
      @assets.get(Constants.right_axle.texture), # texture
      0.0,               # x
      -axle_thickness/2, # y
      distance,          # size-x
      axle_thickness     # size-y
    )

    @level.ctx.restore()
