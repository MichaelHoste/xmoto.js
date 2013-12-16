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
    @rider_style = @assets.get_rider_style("player")

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
    textures = [ @rider_style.torso,    @rider_style.upperleg, @rider_style.lowerleg
                 @rider_style.upperarm, @rider_style.lowerarm ]
    for texture in textures
      @assets.moto.push(texture)

    # Creation of moto parts
    @player_start = @level.entities.player_start
    @head         = @create_head(@player_start.x + @mirror * Constants.head.position.x,
                                 @player_start.y + Constants.head.position.y)

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

    @neck_joint     = @create_neck_joint()
    @ankle_joint    = @create_ankle_joint()
    @wrist_joint    = @create_wrist_joint()
    @knee_joint     = @create_knee_joint()
    @elbow_joint    = @create_elbow_joint()
    @shoulder_joint = @create_shoulder_joint()
    @hip_joint      = @create_hip_joint()

  position: ->
    @moto.body.GetPosition()

  create_head: (x, y)  ->
    # Create fixture
    fixDef = new b2FixtureDef()

    fixDef.shape       = new b2CircleShape(Constants.head.radius)
    fixDef.density     = Constants.head.density
    fixDef.restitution = Constants.head.restitution
    fixDef.friction    = Constants.head.friction
    fixDef.isSensor    = !Constants.head.collisions
    fixDef.filter.groupIndex = -1

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = x
    bodyDef.position.y = y

    bodyDef.userData =
      name: 'rider'

    bodyDef.type = b2Body.b2_dynamicBody

    ## Assign fixture to body and add body to 2D world
    body = @level.world.CreateBody(bodyDef)
    body.CreateFixture(fixDef)

    body

  create_torso: (x, y)  ->
    # Create fixture
    fixDef = new b2FixtureDef()

    fixDef.shape       = new b2PolygonShape()
    fixDef.density     = Constants.torso.density
    fixDef.restitution = Constants.torso.restitution
    fixDef.friction    = Constants.torso.friction
    fixDef.isSensor    = !Constants.torso.collisions
    fixDef.filter.groupIndex = -1

    Physics.create_shape(fixDef, Constants.torso.shape, @mirror == -1)

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = x
    bodyDef.position.y = y

    # Assign body angle
    bodyDef.angle = @mirror * Constants.torso.angle

    bodyDef.userData =
      name: 'rider'

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
    fixDef.isSensor    = !Constants.lower_leg.collisions
    fixDef.filter.groupIndex = -1

    Physics.create_shape(fixDef, Constants.lower_leg.shape, @mirror == -1)

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = x
    bodyDef.position.y = y

    # Assign body angle
    bodyDef.angle = @mirror * Constants.lower_leg.angle

    bodyDef.userData =
      name: 'rider-lower_leg'

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
    fixDef.isSensor    = !Constants.upper_leg.collisions
    fixDef.filter.groupIndex = -1

    Physics.create_shape(fixDef, Constants.upper_leg.shape, @mirror == -1)

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = x
    bodyDef.position.y = y

    # Assign body angle
    bodyDef.angle = @mirror * Constants.upper_leg.angle

    bodyDef.userData =
      name: 'rider'

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
    fixDef.isSensor    = !Constants.lower_arm.collisions
    fixDef.filter.groupIndex = -1

    Physics.create_shape(fixDef, Constants.lower_arm.shape, @mirror == -1)

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = x
    bodyDef.position.y = y

    # Assign body angle
    bodyDef.angle = @mirror * Constants.lower_arm.angle

    bodyDef.userData =
      name: 'rider'

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
    fixDef.isSensor    = !Constants.upper_arm.collisions
    fixDef.filter.groupIndex = -1

    Physics.create_shape(fixDef, Constants.upper_arm.shape, @mirror == -1)

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = x
    bodyDef.position.y = y

    # Assign body angle
    bodyDef.angle = @mirror * Constants.upper_arm.angle

    bodyDef.userData =
      name: 'rider'

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
    Rider.display_rider(@mirror,
                        @neck_joint.GetAnchorA(),
                        @wrist_joint.GetAnchorA(),
                        @elbow_joint.GetAnchorA(),
                        @shoulder_joint.GetAnchorA(),
                        @hip_joint.GetAnchorA(),
                        @knee_joint.GetAnchorA(),
                        @ankle_joint.GetAnchorA(),
                        @level.ctx, @assets, @rider_style, @level.get_render_mode())

  @display_rider: (mirror, neck_anchor, wrist_anchor, elbow_anchor, shoulder_anchor, hip_anchor, knee_anchor, ankle_anchor, ctx, assets, rider_style, mode) ->
    if mode == "normal" or mode == "uglyOver"
      Rider.display_rider_members(mirror, neck_anchor, wrist_anchor, elbow_anchor, shoulder_anchor, hip_anchor, knee_anchor, ankle_anchor, ctx, assets, rider_style, false)
    if mode == "ugly"   or mode == "uglyOver"
      Rider.display_rider_members(mirror, neck_anchor, wrist_anchor, elbow_anchor, shoulder_anchor, hip_anchor, knee_anchor, ankle_anchor, ctx, assets, rider_style, true)

  @display_rider_members: (mirror, neck_anchor, wrist_anchor, elbow_anchor, shoulder_anchor, hip_anchor, knee_anchor, ankle_anchor, ctx, assets, rider_style, ugly) ->
    if ugly
      Rider.display_ugly_head(ctx, rider_style, neck_anchor)                      # head
      Rider.display_ugly_part(ctx, rider_style, hip_anchor,      shoulder_anchor) # display_torso
      Rider.display_ugly_part(ctx, rider_style, hip_anchor,      knee_anchor)     # display_upper_leg
      Rider.display_ugly_part(ctx, rider_style, ankle_anchor,    knee_anchor)     # display_lower_leg
      Rider.display_ugly_part(ctx, rider_style, shoulder_anchor, elbow_anchor)    # display_upper_arm
      Rider.display_ugly_part(ctx, rider_style, elbow_anchor,    wrist_anchor)    # display_lower_arm
    else
      Rider.display_normal_part(ctx, hip_anchor,   shoulder_anchor, assets.get(rider_style.torso),     mirror, -0.27, -0.80, 0.50, 1.15)
      Rider.display_normal_part(ctx, hip_anchor,   knee_anchor,     assets.get(rider_style.upperleg),  mirror, -0.45, -0.13, 0.80, 0.28, 1)
      Rider.display_normal_part(ctx, ankle_anchor, knee_anchor,     assets.get(rider_style.lowerleg),  mirror, -0.17, -0.36, 0.40, 0.66)
      Rider.display_normal_part(ctx, elbow_anchor, shoulder_anchor, assets.get(rider_style.upperarm),  mirror, -0.13, -0.30, 0.25, 0.56)
      Rider.display_normal_part(ctx, elbow_anchor, wrist_anchor,    assets.get(rider_style.lowerarm), -mirror, -0.30, -0.12, 0.56, 0.20, 1)

  @display_ugly_head: (ctx, rider_style, neck_anchor) ->
    ctx.beginPath()
    ctx.strokeStyle=rider_style.ugly_rider_color
    ctx.lineWidth = 0.05
    ctx.arc(neck_anchor.x, neck_anchor.y, Constants.head.radius, 0, 2*Math.PI)
    ctx.stroke()

  @display_ugly_part: (ctx, rider_style, anchor1, anchor2) ->
    ctx.beginPath()
    ctx.strokeStyle=rider_style.ugly_rider_color
    ctx.lineWidth = 0.04
    ctx.moveTo(anchor1.x, anchor1.y)
    ctx.lineTo(anchor2.x, anchor2.y)
    ctx.stroke()

  @display_normal_part: (ctx, anchor1, anchor2, texture, mirror, x, y, sx, sy, i90rot = 0) ->
    ctx.save()
    centerX = (anchor1.x + anchor2.x)/2
    centerY = (anchor1.y + anchor2.y)/2
    angle   = Math2D.angle_between_points(anchor1, anchor2) + mirror*i90rot*Math.PI/2.0
    ctx.translate(centerX, centerY)
    ctx.scale(-mirror, 1)
    ctx.rotate(-mirror * angle)
    ctx.drawImage(texture, x, y, sx, sy)
    ctx.restore()
