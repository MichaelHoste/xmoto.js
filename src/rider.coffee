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

  destroy: ->
    world = @level.world
    world.DestroyBody(@torso)
    world.DestroyBody(@lower_leg)
    world.DestroyBody(@upper_leg)
    world.DestroyBody(@lower_arm)
    world.DestroyBody(@upper_arm)

    world.DestroyJoint(@foot_joint)
    world.DestroyJoint(@hand_joint)
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
                 'playerupperarm', 'playerupperleg', 'rear1' ]
    for texture in textures
      @assets.moto.push(texture)

    # Creation of moto parts
    @player_start = @level.entities.player_start
    @torso        = @create_torso(@player_start.x - 0.24, @player_start.y + 1.87)
    @lower_leg    = @create_lower_leg(@player_start.x + 0.15, @player_start.y + 0.9)
    @upper_leg    = @create_upper_leg(@player_start.x - 0.09, @player_start.y + 1.27)
    @lower_arm    = @create_lower_arm(@player_start.x + 0.07, @player_start.y + 1.52)
    @upper_arm    = @create_upper_arm(@player_start.x - 0.17, @player_start.y + 1.83)

    @foot_joint     = @create_foot_joint()
    @hand_joint     = @create_hand_joint()
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

    b2vertices = [ new b2Vec2(  0.25, -0.575),
                   new b2Vec2(  0.25,  0.575),
                   new b2Vec2( -0.25,  0.575),
                   new b2Vec2( -0.25, -0.575) ]

    fixDef.shape.SetAsArray(b2vertices)

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = x
    bodyDef.position.y = y

    # Assign body angle
    bodyDef.angle = -Math.PI/20

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

    b2vertices = [ new b2Vec2(  0.2, -0.33),
                   new b2Vec2(  0.2,  0.33),
                   new b2Vec2( -0.2,  0.33),
                   new b2Vec2( -0.2, -0.33) ]

    fixDef.shape.SetAsArray(b2vertices)

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = x
    bodyDef.position.y = y

    # Assign body angle
    bodyDef.angle = -Math.PI/6.0

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

    b2vertices = [ new b2Vec2(  0.4, -0.14),
                   new b2Vec2(  0.4,  0.14),
                   new b2Vec2( -0.4,  0.14),
                   new b2Vec2( -0.4, -0.14) ]

    fixDef.shape.SetAsArray(b2vertices)

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = x
    bodyDef.position.y = y

    # Assign body angle
    bodyDef.angle = -Math.PI/12.0

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

    b2vertices = [ new b2Vec2(  0.28, -0.1),
                   new b2Vec2(  0.28,  0.1),
                   new b2Vec2( -0.28,  0.1),
                   new b2Vec2( -0.28, -0.1) ]

    fixDef.shape.SetAsArray(b2vertices)

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = x
    bodyDef.position.y = y

    # Assign body angle
    bodyDef.angle = -Math.PI/10.0

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

    b2vertices = [ new b2Vec2(  0.125, -0.28),
                   new b2Vec2(  0.125,  0.28),
                   new b2Vec2( -0.125,  0.28),
                   new b2Vec2( -0.125, -0.28) ]

    fixDef.shape.SetAsArray(b2vertices)

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = x
    bodyDef.position.y = y

    # Assign body angle
    bodyDef.angle = Math.PI/9.0

    bodyDef.type = b2Body.b2_dynamicBody

    # Assign fixture to body and add body to 2D world
    body = @level.world.CreateBody(bodyDef)
    body.CreateFixture(fixDef)

    body

  set_joint_commons: (joint) ->
    joint.lowerAngle = Math.PI/20
    joint.upperAngle = Math.PI/20
    joint.enableLimit = true
    joint.maxMotorTorque = 1.0

  create_foot_joint: ->
    position = @lower_leg.GetWorldCenter()
    rotation_axe = { x: position.x - 0.2, y: position.y - 0.2 }

    jointDef = new b2RevoluteJointDef()
    jointDef.Initialize(@lower_leg, @moto.body, rotation_axe)
    @set_joint_commons(jointDef)
    @level.world.CreateJoint(jointDef)

  create_knee_joint: ->
    position = @lower_leg.GetWorldCenter()
    rotation_axe = { x: position.x + 0.07, y: position.y + 0.28 }

    jointDef = new b2RevoluteJointDef()
    jointDef.Initialize(@lower_leg, @upper_leg, rotation_axe)
    @set_joint_commons(jointDef)
    @level.world.CreateJoint(jointDef)

  create_hand_joint: ->
    position = @lower_arm.GetWorldCenter()
    rotation_axe = { x: position.x + 0.25, y: position.y - 0.07 }

    jointDef = new b2RevoluteJointDef()
    jointDef.Initialize(@lower_arm, @moto.body, rotation_axe)
    @set_joint_commons(jointDef)
    @level.world.CreateJoint(jointDef)

  create_elbow_joint: ->
    position = @upper_arm.GetWorldCenter()
    rotation_axe = { x: position.x + 0.05, y: position.y - 0.2 }

    jointDef = new b2RevoluteJointDef()
    jointDef.Initialize(@upper_arm, @lower_arm, rotation_axe)
    @set_joint_commons(jointDef)
    @level.world.CreateJoint(jointDef)

  create_shoulder_joint: ->
    position = @upper_arm.GetWorldCenter()
    rotation_axe = { x: position.x - 0.12, y: position.y + 0.22 }

    jointDef = new b2RevoluteJointDef()
    jointDef.Initialize(@torso, @upper_arm, rotation_axe)
    @set_joint_commons(jointDef)
    @level.world.CreateJoint(jointDef)

  create_hip_joint: ->
    position = @upper_leg.GetWorldCenter()
    rotation_axe = { x: position.x - 0.27, y: position.y + 0.1 }

    jointDef = new b2RevoluteJointDef()
    jointDef.Initialize(@torso, @upper_leg, rotation_axe)
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
    @level.ctx.scale(1, -1)
    @level.ctx.rotate(-angle)

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
    @level.ctx.scale(1, -1)
    @level.ctx.rotate(-angle)

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
    @level.ctx.scale(1, -1)
    @level.ctx.rotate(-angle)

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
    @level.ctx.scale(1, 1)
    @level.ctx.rotate(angle)

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
    @level.ctx.scale(1, -1)
    @level.ctx.rotate(-angle)

    @level.ctx.drawImage(
      @assets.get('playerupperarm'), # texture
      -0.125, # x
      -0.28, # y
       0.25, # size-x
       0.56  # size-y
    )

    @level.ctx.restore()
