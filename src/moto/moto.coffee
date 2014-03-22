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
    @world    = level.physics.world
    @mirror   = if mirror then -1 else 1
    @rider    = new Rider(level, this)
    @dead     = false

  destroy: ->
    @rider.destroy()

    @world.DestroyBody(@body)
    @world.DestroyBody(@left_wheel)
    @world.DestroyBody(@right_wheel)
    @world.DestroyBody(@left_axle)
    @world.DestroyBody(@right_axle)

    @world.DestroyJoint(@left_revolute_joint)
    @world.DestroyJoint(@left_prismatic_joint)
    @world.DestroyJoint(@right_revolute_joint)
    @world.DestroyJoint(@right_prismatic_joint)

  init: ->
    # Assets
    parts = [ Constants.body, Constants.left_wheel, Constants.right_wheel,
              Constants.left_axle, Constants.right_axle ]
    for part in parts
      @assets.moto.push(part.texture)

    # Creation of moto parts
    @player_start = @level.entities.player_start

    @body         = @create_body()
    @left_wheel   = @create_wheel(Constants.left_wheel)
    @right_wheel  = @create_wheel(Constants.right_wheel)
    @left_axle    = @create_axle(Constants.left_axle)
    @right_axle   = @create_axle(Constants.right_axle)

    @left_revolute_joint  = @create_revolute_joint(@left_axle,  @left_wheel)
    @right_revolute_joint = @create_revolute_joint(@right_axle, @right_wheel)

    @left_prismatic_joint  = @create_prismatic_joint(@left_axle,  Constants.left_suspension)
    @right_prismatic_joint = @create_prismatic_joint(@right_axle, Constants.right_suspension)

    @rider.init()

  position: ->
    @body.GetPosition()

  create_body: ->
    # Create fixture
    fixDef = new b2FixtureDef()

    fixDef.shape       =  new b2PolygonShape()
    fixDef.density     =  Constants.body.density
    fixDef.restitution =  Constants.body.restitution
    fixDef.friction    =  Constants.body.friction
    fixDef.isSensor    = !Constants.body.collisions
    fixDef.filter.groupIndex = -1

    Physics.create_shape(fixDef, Constants.body.shape, @mirror == -1)

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = @player_start.x + @mirror * Constants.body.position.x
    bodyDef.position.y = @player_start.y +           Constants.body.position.y

    bodyDef.userData =
      name: 'moto'

    bodyDef.type = b2Body.b2_dynamicBody

    # Assign fixture to body and add body to 2D world
    body = @world.CreateBody(bodyDef)
    body.CreateFixture(fixDef)

    body

  create_wheel: (part_constants) ->
    # Create fixture
    fixDef = new b2FixtureDef()

    fixDef.shape       =  new b2CircleShape(part_constants.radius)
    fixDef.density     =  part_constants.density
    fixDef.restitution =  part_constants.restitution
    fixDef.friction    =  part_constants.friction
    fixDef.isSensor    = !part_constants.collisions
    fixDef.filter.groupIndex = -1

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = @player_start.x + @mirror * part_constants.position.x
    bodyDef.position.y = @player_start.y +           part_constants.position.y

    bodyDef.userData =
      name: 'moto'

    bodyDef.type = b2Body.b2_dynamicBody

    # Assign fixture to body and add body to 2D world
    wheel = @world.CreateBody(bodyDef)
    wheel.CreateFixture(fixDef)

    wheel

  create_axle: (part_constants) ->
    # Create fixture
    fixDef = new b2FixtureDef()

    fixDef.shape       =  new b2PolygonShape()
    fixDef.density     =  part_constants.density
    fixDef.restitution =  part_constants.restitution
    fixDef.friction    =  part_constants.friction
    fixDef.isSensor    = !part_constants.collisions
    fixDef.filter.groupIndex = -1

    Physics.create_shape(fixDef, part_constants.shape, @mirror == -1)

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = @player_start.x + @mirror * part_constants.position.x
    bodyDef.position.y = @player_start.y +           part_constants.position.y

    bodyDef.userData =
      name: 'moto'

    bodyDef.type = b2Body.b2_dynamicBody

    # Assign fixture to body and add body to 2D world
    body = @world.CreateBody(bodyDef)
    body.CreateFixture(fixDef)

    body

  create_revolute_joint: (axle, wheel) ->
    jointDef = new b2RevoluteJointDef()
    jointDef.Initialize(axle, wheel, wheel.GetWorldCenter())
    @world.CreateJoint(jointDef)

  create_prismatic_joint: (axle, part_constants) ->
    jointDef = new b2PrismaticJointDef()
    angle = part_constants.angle
    jointDef.Initialize(@body, axle, axle.GetWorldCenter(), new b2Vec2(@mirror * angle.x, angle.y))
    jointDef.enableLimit      = true
    jointDef.lowerTranslation = part_constants.lower_translation
    jointDef.upperTranslation = part_constants.upper_translation
    jointDef.enableMotor      = true
    jointDef.collideConnected = false
    @world.CreateJoint(jointDef)

  display: ->
    return false if Constants.debug

    @display_wheel(      @left_wheel,  Constants.left_wheel)
    @display_wheel(      @right_wheel, Constants.right_wheel)
    @display_left_axle(  @left_axle,   Constants.left_axle)
    @display_right_axle( @right_axle,  Constants.right_axle)
    @display_body(       @body,        Constants.body)
    @rider.display()

  display_wheel: (part, part_constants) ->
    Moto.display_wheel(@level, part, part_constants, @mirror)

  @display_wheel: (level, part, part_constants, mirror, texture_prefix = '') ->
    # Get position from box2D object of replay
    position = if part.GetPosition then part.GetPosition() else part.position
    angle    = if part.GetAngle    then part.GetAngle()    else part.angle
    texture  = part_constants["#{texture_prefix}texture"]

    level.ctx.save()
    level.ctx.translate(position.x, position.y)
    level.ctx.rotate(angle)

    level.ctx.drawImage(
      level.assets.get(texture), # texture
      -part_constants.radius,    # x
      -part_constants.radius,    # y
       part_constants.radius*2,  # size-x
       part_constants.radius*2   # size-y
    )

    level.ctx.restore()

  display_body: (part, part_constants) ->
    Moto.display_body(@level, part, part_constants, @mirror)

  @display_body: (level, part, part_constants, mirror, texture_prefix = '') ->
    # Get position from box2D object of replay
    position = if part.GetPosition then part.GetPosition() else part.position
    angle    = if part.GetAngle    then part.GetAngle()    else part.angle
    texture  = part_constants["#{texture_prefix}texture"]

    level.ctx.save()
    level.ctx.translate(position.x, position.y)
    level.ctx.scale(mirror, -1)
    level.ctx.rotate(mirror*(-angle))

    level.ctx.drawImage(
      level.assets.get(texture),        # texture
      -part_constants.texture_size.x/2, # x
      -part_constants.texture_size.y/2, # y
       part_constants.texture_size.x,   # size-x
       part_constants.texture_size.y    # size-y
    )

    level.ctx.restore()

  @display_axle_common: (level, body, wheel_position, axle_position, axle_thickness, mirror, texture) ->
    body_position = if body.GetPosition then body.GetPosition() else body.position
    body_angle    = if body.GetAngle    then body.GetAngle()    else body.angle

    # Adjusted position depending of rotation of body
    axle_adjusted_position = Math2D.rotate_point(axle_position, body_angle, body_position)

    # Distance
    distance = Math2D.distance_between_points(wheel_position, axle_adjusted_position)

    # Angle
    angle = Math2D.angle_between_points(axle_adjusted_position, wheel_position) + mirror * Math.PI/2

    # Draw texture
    level.ctx.save()
    level.ctx.translate(wheel_position.x, wheel_position.y)
    level.ctx.scale(mirror, -1)
    level.ctx.rotate(mirror*(-angle))

    level.ctx.drawImage(
      level.assets.get(texture), # texture
      0.0,                       # x
      -axle_thickness/2,         # y
      distance,                  # size-x
      axle_thickness             # size-y
    )

    level.ctx.restore()

  display_left_axle: (part, part_constants) ->
    Moto.display_left_axle(@level, part, part_constants, @body, @left_wheel, @mirror)

  @display_left_axle: (level, part, part_constants, body, wheel, mirror, texture_prefix = '') ->
    axle_thickness = 0.09

    wheel_position = if wheel.GetPosition then wheel.GetPosition() else wheel.position
    wheel_position =
      x: wheel_position.x - mirror * axle_thickness/2.0
      y: wheel_position.y - 0.025

    # Position relative to center of body
    axle_position =
      x: -0.17 * mirror
      y: -0.30

    texture = part_constants["#{texture_prefix}texture"]

    Moto.display_axle_common(level, body, wheel_position, axle_position, axle_thickness, mirror, texture)

  display_right_axle: (part, part_constants) ->
    Moto.display_right_axle(@level, part, part_constants, @body, @right_wheel, @mirror)

  @display_right_axle: (level, part, part_constants, body, wheel, mirror, texture_prefix = '') ->
    axle_thickness = 0.07

    wheel_position = if wheel.GetPosition then wheel.GetPosition() else wheel.position
    wheel_position =
      x: wheel_position.x + mirror * axle_thickness/2.0 - mirror * 0.03
      y: wheel_position.y - 0.045

    # Position relative to center of body
    axle_position =
      x: 0.52 * mirror
      y: 0.025

    texture = part_constants["#{texture_prefix}texture"]

    Moto.display_axle_common(level, body, wheel_position, axle_position, axle_thickness, mirror, texture)

