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
    @world  = level.physics.world
    @moto   = moto
    @mirror = moto.mirror
    @ghost  = moto.ghost

  destroy: ->
    @world.DestroyBody(@head)
    @world.DestroyBody(@torso)
    @world.DestroyBody(@lower_leg)
    @world.DestroyBody(@upper_leg)
    @world.DestroyBody(@lower_arm)
    @world.DestroyBody(@upper_arm)

    @level.camera.neutral_z_container.removeChild(@head_sprite)
    @level.camera.neutral_z_container.removeChild(@torso_sprite)
    @level.camera.neutral_z_container.removeChild(@lower_leg_sprite)
    @level.camera.neutral_z_container.removeChild(@upper_leg_sprite)
    @level.camera.neutral_z_container.removeChild(@lower_arm_sprite)
    @level.camera.neutral_z_container.removeChild(@upper_arm_sprite)

  load_assets: ->
    parts = [ Constants.torso, Constants.upper_leg, Constants.lower_leg,
              Constants.upper_arm, Constants.lower_arm ]
    for part in parts
      if @ghost
        @assets.moto.push(part.ghost_texture)
      else
        @assets.moto.push(part.texture)

  init_physics_parts: ->
    @player_start = @level.entities.player_start

    @head      = @create_head()
    @torso     = @create_part(Constants.torso,     'torso')
    @lower_leg = @create_part(Constants.lower_leg, 'lower_leg')
    @upper_leg = @create_part(Constants.upper_leg, 'upper_leg')
    @lower_arm = @create_part(Constants.lower_arm, 'lower_arm')
    @upper_arm = @create_part(Constants.upper_arm, 'upper_arm')

    @neck_joint     = @create_neck_joint()
    @ankle_joint    = @create_joint(Constants.ankle,    @lower_leg, @moto.body)
    @wrist_joint    = @create_joint(Constants.wrist,    @lower_arm, @moto.body)
    @knee_joint     = @create_joint(Constants.knee,     @lower_leg, @upper_leg)
    @elbow_joint    = @create_joint(Constants.elbow,    @upper_arm, @lower_arm)
    @shoulder_joint = @create_joint(Constants.shoulder, @upper_arm, @torso, true)
    @hip_joint      = @create_joint(Constants.hip,      @upper_leg, @torso, true)

  init_sprites: ->
    for part in ['torso', 'upper_leg', 'lower_leg', 'upper_arm', 'lower_arm']
      if @ghost
        asset_name = Constants[part].ghost_texture
      else
        asset_name = Constants[part].texture

      @["#{part}_sprite"] = new PIXI.Sprite.from(@assets.get_url(asset_name))
      @level.camera.neutral_z_container.addChild(@["#{part}_sprite"])

  position: ->
    @moto.body.GetPosition()

  eject: ->
    if !@moto.dead
      @level.listeners.kill_moto(@moto)

      force_vector          = { x: 150.0 * @moto.mirror, y: 0 }
      eject_angle           = @mirror * @moto.body.GetAngle() + Math.PI/4.0
      adjusted_force_vector = Math2D.rotate_point(force_vector, eject_angle, {x: 0, y: 0})
      @torso.ApplyForce(adjusted_force_vector, @torso.GetWorldCenter())

  create_head: ->
    # Create fixture
    fixDef = new b2FixtureDef()

    fixDef.shape       =  new b2CircleShape(Constants.head.radius)
    fixDef.density     =  Constants.head.density
    fixDef.restitution =  Constants.head.restitution
    fixDef.friction    =  Constants.head.friction
    fixDef.isSensor    = !Constants.head.collisions
    fixDef.filter.groupIndex = -1

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = @player_start.x + @mirror * Constants.head.position.x
    bodyDef.position.y = @player_start.y +           Constants.head.position.y

    bodyDef.userData =
      name:  'rider'
      type:  if @ghost then 'ghost' else 'player'
      part:  'head'
      rider: this

    bodyDef.type = b2Body.b2_dynamicBody

    ## Assign fixture to body and add body to 2D world
    body = @world.CreateBody(bodyDef)
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
      name:  'rider'
      type:  if @ghost then 'ghost' else 'player'
      part:  name
      rider: this

    bodyDef.type = b2Body.b2_dynamicBody

    # Assign fixture to body and add body to 2D world
    body = @world.CreateBody(bodyDef)
    body.CreateFixture(fixDef)

    body

  set_joint_commons: (joint) ->
    if @mirror == 1
      joint.lowerAngle     = - Math.PI/15
      joint.upperAngle     =   Math.PI/108
    else if @mirror == -1
      joint.lowerAngle     = - Math.PI/108
      joint.upperAngle     =   Math.PI/15
    joint.enableLimit    = true

  create_neck_joint: ->
    position = @head.GetWorldCenter()
    axe =
      x: position.x
      y: position.y

    jointDef = new b2RevoluteJointDef()
    jointDef.Initialize(@head, @torso, axe)
    @world.CreateJoint(jointDef)

  create_joint: (joint_constants, part1, part2, invert_joint=false) ->
    position = part1.GetWorldCenter()
    axe =
      x: position.x + @mirror * joint_constants.axe_position.x
      y: position.y +           joint_constants.axe_position.y

    jointDef = new b2RevoluteJointDef()
    if invert_joint
      jointDef.Initialize(part2, part1, axe)
    else
      jointDef.Initialize(part1, part2, axe)
    @set_joint_commons(jointDef)
    @world.CreateJoint(jointDef)

  update: (visible) ->
    if !Constants.debug_physics
      @update_part(@torso,     'torso',     visible)
      @update_part(@upper_leg, 'upper_leg', visible)
      @update_part(@lower_leg, 'lower_leg', visible)
      @update_part(@upper_arm, 'upper_arm', visible)
      @update_part(@lower_arm, 'lower_arm', visible)

  update_part: (part, name, visible) ->
    sprite = @["#{name}_sprite"]
    sprite.visible = visible

    if visible
      part_constants = Constants[name]

      position = part.GetPosition()
      angle    = part.GetAngle()
      texture  = if @ghost then part_constants.ghost_texture else part_constants.texture

      sprite.width    = part_constants.texture_size.x
      sprite.height   = part_constants.texture_size.y
      sprite.anchor.x = 0.5
      sprite.anchor.y = 0.5
      sprite.x        =  position.x
      sprite.y        = -position.y
      sprite.rotation = -angle
      sprite.scale.x  = @mirror * Math.abs(sprite.scale.x)
