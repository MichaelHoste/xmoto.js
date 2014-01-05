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
    world.DestroyBody(@head)
    world.DestroyBody(@torso)
    world.DestroyBody(@lower_leg)
    world.DestroyBody(@upper_leg)
    world.DestroyBody(@lower_arm)
    world.DestroyBody(@upper_arm)

    world.DestroyJoint(@neck_joint)
    world.DestroyJoint(@ankle_joint)
    world.DestroyJoint(@wrist_joint)
    world.DestroyJoint(@knee_joint)
    world.DestroyJoint(@elbow_joint)
    world.DestroyJoint(@shoulder_joint)
    world.DestroyJoint(@hip_joint)

  init: ->
    # Assets
    parts = [ Constants.torso, Constants.upper_leg, Constants.lower_leg,
              Constants.upper_arm, Constants.lower_arm ]
    for part in parts
      @assets.moto.push(part.texture)

    # Creation of moto parts
    @player_start = @level.entities.player_start

    @head      = @create_head(Constants.head,      'head')
    @torso     = @create_part(Constants.torso,     'torso')
    @lower_leg = @create_part(Constants.lower_leg, 'lower_leg')
    @upper_leg = @create_part(Constants.upper_leg, 'upper_leg')
    @lower_arm = @create_part(Constants.lower_arm, 'lower_arm')
    @upper_arm = @create_part(Constants.upper_arm, 'upper_arm')

    @neck_joint     = @create_neck_joint()
    @ankle_joint    = @create_ankle_joint()
    @wrist_joint    = @create_wrist_joint()
    @knee_joint     = @create_knee_joint()
    @elbow_joint    = @create_elbow_joint()
    @shoulder_joint = @create_shoulder_joint()
    @hip_joint      = @create_hip_joint()

  position: ->
    @moto.body.GetPosition()

  create_head: (part_constants, name)  ->
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
      name: 'rider'
      part: name

    bodyDef.type = b2Body.b2_dynamicBody

    ## Assign fixture to body and add body to 2D world
    body = @level.world.CreateBody(bodyDef)
    body.CreateFixture(fixDef)

    body

  create_part: (part_constants, name) ->
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

    # Assign body angle
    bodyDef.angle = @mirror * part_constants.angle

    bodyDef.userData =
      name: 'rider'
      part: name

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
    #joint.maxMotorTorque = 1.0
    #joint.enableMotor    = true

  create_neck_joint: ->
    position = @head.GetWorldCenter()
    axe =
      x: position.x
      y: position.y

    jointDef = new b2RevoluteJointDef()
    jointDef.Initialize(@head, @torso, axe)
    @set_joint_commons(jointDef)
    @level.world.CreateJoint(jointDef)

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

  display: ->
    @display_part(@torso,     Constants.torso)
    @display_part(@upper_leg, Constants.upper_leg)
    @display_part(@lower_leg, Constants.lower_leg)
    @display_part(@upper_arm, Constants.upper_arm)
    @display_part(@lower_arm, Constants.lower_arm)

  display_part: (part, part_constants) ->
    # Position
    position = part.GetPosition()

    # Angle
    angle = part.GetAngle()

    # Draw texture
    @level.ctx.save()
    @level.ctx.translate(position.x, position.y)
    @level.ctx.scale(@mirror, -1)
    @level.ctx.rotate(@mirror * (-angle))

    @level.ctx.drawImage(
      @assets.get(part_constants.texture), # texture
      -part_constants.texture_size.x/2,    # x
      -part_constants.texture_size.y/2,    # y
       part_constants.texture_size.x,      # size-x
       part_constants.texture_size.y       # size-y
    )

    @level.ctx.restore()
