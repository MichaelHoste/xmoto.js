b2Vec2              = Box2D.Common.Math.b2Vec2
b2BodyDef           = Box2D.Dynamics.b2BodyDef
b2Body              = Box2D.Dynamics.b2Body
b2FixtureDef        = Box2D.Dynamics.b2FixtureDef
b2Fixture           = Box2D.Dynamics.b2Fixture
b2PolygonShape      = Box2D.Collision.Shapes.b2PolygonShape
b2CircleShape       = Box2D.Collision.Shapes.b2CircleShape
b2PrismaticJointDef = Box2D.Dynamics.Joints.b2PrismaticJointDef
b2RevoluteJointDef  = Box2D.Dynamics.Joints.b2RevoluteJointDef

class Rider

  constructor: (level, moto) ->
    @level  = level
    @assets = level.assets
    @moto   = moto
    @mirror = @moto.mirror

  destroy: ->
    world = @level.world
    world.DestroyBody(@torso)
    world.DestroyBody(@lower_leg)
    world.DestroyBody(@upper_leg)
    world.DestroyBody(@lower_arm)
    world.DestroyBody(@upper_arm)

    world.DestroyJoint(@ankle_joint)
    world.DestroyJoint(@wrist_joint)
    world.DestroyJoint(@knee_joint)
    world.DestroyJoint(@elbow_joint)
    world.DestroyJoint(@shoulder_joint)
    world.DestroyJoint(@hip_joint)

  display: ->
    @display_torso()
    @display_upper_leg()
    @display_lower_leg()
    @display_upper_arm()
    @display_lower_arm()

  init: ->
    # Assets
    textures = [ 'playerlowerarm', 'playerlowerleg', 'playertorso',
                 'playerupperarm', 'playerupperleg' ]
    for texture in textures
      @assets.moto.push(texture)

    # Creation of moto parts
    @player_start = @level.entities.player_start
    @torso        = @create_torso(@player_start.x + @mirror * Constants.torso.position.x,
                                  @player_start.y + Constants.torso.position.y)

    @lower_leg    = @create_lower_leg(@player_start.x + @mirror * Constants.lower_leg.position.x,
                                      @player_start.y + Constants.lower_leg.position.y)

    @upper_leg    = @create_upper_leg(@player_start.x + @mirror * Constants.upper_leg.position.x,
                                      @player_start.y + Constants.upper_leg.position.y)

    @lower_arm    = @create_lower_arm(@player_start.x + @mirror * Constants.lower_arm.position.x,
                                      @player_start.y + Constants.lower_arm.position.y)

    @upper_arm    = @create_upper_arm(@player_start.x + @mirror * Constants.upper_arm.position.x,
                                      @player_start.y + Constants.upper_arm.position.y)

    @ankle_joint    = @create_ankle_joint()
    @wrist_joint    = @create_wrist_joint()
    @knee_joint     = @create_knee_joint()
    @elbow_joint    = @create_elbow_joint()
    @shoulder_joint = @create_shoulder_joint()
    @hip_joint      = @create_hip_joint()

  position: ->
    @moto.body.GetPosition()

  create_torso: (x, y)  ->
    # Create fixture
    fixDef = new b2FixtureDef()

    fixDef.shape       = new b2PolygonShape()
    fixDef.density     = Constants.torso.density
    fixDef.restitution = Constants.torso.restitution
    fixDef.friction    = Constants.torso.friction
    fixDef.filter.groupIndex = -1

    Physics.create_shape(fixDef, Constants.torso.collision_box, @mirror == -1)

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = x
    bodyDef.position.y = y

    # Assign body angle
    bodyDef.angle = @mirror * Constants.torso.angle

    bodyDef.userData = 'rider'

    bodyDef.type = b2Body.b2_dynamicBody

    # Assign fixture to body and add body to 2D world
    body = @level.world.CreateBody(bodyDef)
    body.CreateFixture(fixDef)

    body

  create_lower_leg: (x, y) ->
    # Create fixture
    fixDef = new b2FixtureDef()

    fixDef.shape       = new b2PolygonShape()
    fixDef.density     = Constants.lower_leg.density
    fixDef.restitution = Constants.lower_leg.restitution
    fixDef.friction    = Constants.lower_leg.friction
    fixDef.filter.groupIndex = -1

    Physics.create_shape(fixDef, Constants.lower_leg.collision_box, @mirror == -1)

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = x
    bodyDef.position.y = y

    # Assign body angle
    bodyDef.angle = @mirror * Constants.lower_leg.angle

    bodyDef.userData = 'rider'

    bodyDef.type = b2Body.b2_dynamicBody

    # Assign fixture to body and add body to 2D world
    body = @level.world.CreateBody(bodyDef)
    body.CreateFixture(fixDef)

    body

  create_upper_leg: (x, y) ->
    # Create fixture
    fixDef = new b2FixtureDef()

    fixDef.shape       = new b2PolygonShape()
    fixDef.density     = Constants.upper_leg.density
    fixDef.restitution = Constants.upper_leg.restitution
    fixDef.friction    = Constants.upper_leg.friction
    fixDef.filter.groupIndex = -1

    Physics.create_shape(fixDef, Constants.upper_leg.collision_box, @mirror == -1)

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = x
    bodyDef.position.y = y

    # Assign body angle
    bodyDef.angle = @mirror * Constants.upper_leg.angle

    bodyDef.userData = 'rider'

    bodyDef.type = b2Body.b2_dynamicBody

    # Assign fixture to body and add body to 2D world
    body = @level.world.CreateBody(bodyDef)
    body.CreateFixture(fixDef)

    body

  create_lower_arm: (x, y) ->
    # Create fixture
    fixDef = new b2FixtureDef()

    fixDef.shape       = new b2PolygonShape()
    fixDef.density     = Constants.lower_arm.density
    fixDef.restitution = Constants.lower_arm.restitution
    fixDef.friction    = Constants.lower_arm.friction
    fixDef.filter.groupIndex = -1

    Physics.create_shape(fixDef, Constants.lower_arm.collision_box, @mirror == -1)

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = x
    bodyDef.position.y = y

    # Assign body angle
    bodyDef.angle = @mirror * Constants.lower_arm.angle

    bodyDef.userData = 'rider'

    bodyDef.type = b2Body.b2_dynamicBody

    # Assign fixture to body and add body to 2D world
    body = @level.world.CreateBody(bodyDef)
    body.CreateFixture(fixDef)

    body

  create_upper_arm: (x, y) ->
    # Create fixture
    fixDef = new b2FixtureDef()

    fixDef.shape       = new b2PolygonShape()
    fixDef.density     = Constants.upper_arm.density
    fixDef.restitution = Constants.upper_arm.restitution
    fixDef.friction    = Constants.upper_arm.friction
    fixDef.filter.groupIndex = -1

    Physics.create_shape(fixDef, Constants.upper_arm.collision_box, @mirror == -1)

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = x
    bodyDef.position.y = y

    # Assign body angle
    bodyDef.angle = @mirror * Constants.upper_arm.angle

    bodyDef.userData = 'rider'

    bodyDef.type = b2Body.b2_dynamicBody

    # Assign fixture to body and add body to 2D world
    body = @level.world.CreateBody(bodyDef)
    body.CreateFixture(fixDef)

    body

  set_joint_commons: (joint) ->
    if @mirror == 1
      joint.lowerAngle     = - Math.PI/15
      joint.upperAngle     =   Math.PI/180
    else if @mirror == -1
      joint.lowerAngle     = - Math.PI/180
      joint.upperAngle     =   Math.PI/15
    joint.enableLimit    = true
    joint.maxMotorTorque = 0
    joint.enableMotor    = true

  create_ankle_joint: ->
    position = @lower_leg.GetWorldCenter()
    axe =
      x: position.x + @mirror * Constants.ankle.axe_position.x
      y: position.y + Constants.ankle.axe_position.y

    jointDef = new b2RevoluteJointDef()
    jointDef.Initialize(@lower_leg, @moto.body, axe)
    @set_joint_commons(jointDef)
    @level.world.CreateJoint(jointDef)

  create_knee_joint: ->
    position = @lower_leg.GetWorldCenter()
    axe =
      x: position.x + @mirror * Constants.knee.axe_position.x
      y: position.y + Constants.knee.axe_position.y

    jointDef = new b2RevoluteJointDef()
    jointDef.Initialize(@lower_leg, @upper_leg, axe)
    @set_joint_commons(jointDef)
    @level.world.CreateJoint(jointDef)

  create_wrist_joint: ->
    position = @lower_arm.GetWorldCenter()
    axe =
      x: position.x + @mirror * Constants.wrist.axe_position.x
      y: position.y + Constants.wrist.axe_position.y

    jointDef = new b2RevoluteJointDef()
    jointDef.Initialize(@lower_arm, @moto.body, axe)
    @set_joint_commons(jointDef)
    @level.world.CreateJoint(jointDef)

  create_elbow_joint: ->
    position = @upper_arm.GetWorldCenter()
    axe =
      x: position.x + @mirror * Constants.elbow.axe_position.x
      y: position.y + Constants.elbow.axe_position.y

    jointDef = new b2RevoluteJointDef()
    jointDef.Initialize(@upper_arm, @lower_arm, axe)
    @set_joint_commons(jointDef)
    @level.world.CreateJoint(jointDef)

  create_shoulder_joint: ->
    position = @upper_arm.GetWorldCenter()
    axe =
      x: position.x + @mirror * Constants.shoulder.axe_position.x
      y: position.y + Constants.shoulder.axe_position.y

    jointDef = new b2RevoluteJointDef()
    jointDef.Initialize(@torso, @upper_arm, axe)
    @set_joint_commons(jointDef)
    @level.world.CreateJoint(jointDef)

  create_hip_joint: ->
    position = @upper_leg.GetWorldCenter()
    axe =
      x: position.x + @mirror * Constants.hip.axe_position.x
      y: position.y + Constants.hip.axe_position.y

    jointDef = new b2RevoluteJointDef()
    jointDef.Initialize(@torso, @upper_leg, axe)
    @set_joint_commons(jointDef)
    @level.world.CreateJoint(jointDef)

  display_torso: ->
    # Position
    position = @torso.GetPosition()

    # Angle
    angle = @torso.GetAngle()

    # Draw texture
    @level.ctx.save()
    @level.ctx.translate(position.x, position.y)
    @level.ctx.scale(1*@mirror, -1)
    @level.ctx.rotate(@mirror * (-angle))

    @level.ctx.drawImage(
      @assets.get('playertorso'), # texture
      -0.25,   # x
      -0.575, # y
       0.5,   # size-x
       1.15   # size-y
    )

    @level.ctx.restore()

  display_lower_leg: ->
    # Position
    position = @lower_leg.GetPosition()

    # Angle
    angle = @lower_leg.GetAngle()

    # Draw texture
    @level.ctx.save()
    @level.ctx.translate(position.x, position.y)
    @level.ctx.scale(1*@mirror, -1)
    @level.ctx.rotate(@mirror * (-angle))

    @level.ctx.drawImage(
      @assets.get('playerlowerleg'), # texture
      -0.2,  # x
      -0.33, # y
       0.40, # size-x
       0.66  # size-y
    )

    @level.ctx.restore()

  display_upper_leg: ->
    # Position
    position = @upper_leg.GetPosition()

    # Angle
    angle = @upper_leg.GetAngle()

    # Draw texture
    @level.ctx.save()
    @level.ctx.translate(position.x, position.y)
    @level.ctx.scale(1*@mirror, -1)
    @level.ctx.rotate(@mirror * (-angle))

    @level.ctx.drawImage(
      @assets.get('playerupperleg'), # texture
      -0.40, # x
      -0.14, # y
       0.80, # size-x
       0.28  # size-y
    )

    @level.ctx.restore()

  display_lower_arm: ->
    # Position
    position = @lower_arm.GetPosition()

    # Angle
    angle = @lower_arm.GetAngle()

    # Draw texture
    @level.ctx.save()
    @level.ctx.translate(position.x, position.y)
    @level.ctx.scale(1*@mirror, 1)
    @level.ctx.rotate(@mirror * angle)

    @level.ctx.drawImage(
      @assets.get('playerlowerarm'), # texture
      -0.28,  # x
      -0.10, # y
       0.56, # size-x
       0.20  # size-y
    )

    @level.ctx.restore()

  display_upper_arm: ->
    # Position
    position = @upper_arm.GetPosition()

    # Angle
    angle = @upper_arm.GetAngle()

    # Draw texture
    @level.ctx.save()
    @level.ctx.translate(position.x, position.y)
    @level.ctx.scale(1*@mirror, -1)
    @level.ctx.rotate(@mirror * (-angle))

    @level.ctx.drawImage(
      @assets.get('playerupperarm'), # texture
      -0.125, # x
      -0.28, # y
       0.25, # size-x
       0.56  # size-y
    )

    @level.ctx.restore()
