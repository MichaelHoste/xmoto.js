Circle         = planck.Circle
Polygon        = planck.Polygon
PrismaticJoint = planck.PrismaticJoint
RevoluteJoint  = planck.RevoluteJoint
AABB           = planck.AABB

class Moto

  constructor: (level, ghost = false) ->
    @level  = level
    @assets = level.assets
    @world  = level.physics.world
    @mirror = 1                    # 1 = right-oriented, -1 = left-oriented
    @dead   = false
    @ghost  = ghost
    @rider  = new Rider(level, this)

  destroy: ->
    @rider.destroy()

    # physics
    @world.destroyBody(@body)
    @world.destroyBody(@left_wheel)
    @world.destroyBody(@right_wheel)
    @world.destroyBody(@left_axle)
    @world.destroyBody(@right_axle)

    # graphics
    @level.layers.static_level.removeChild(@body_sprite)
    @level.layers.static_level.removeChild(@left_wheel_sprite)
    @level.layers.static_level.removeChild(@right_wheel_sprite)
    @level.layers.static_level.removeChild(@left_axle_sprite)
    @level.layers.static_level.removeChild(@right_axle_sprite)

  load_assets: ->
    parts = [ Constants.body, Constants.left_wheel, Constants.right_wheel,
              Constants.left_axle, Constants.right_axle ]
    for part in parts
      if @ghost
        @assets.moto.push(part.ghost_texture)
      else
        @assets.moto.push(part.texture)

    @rider.load_assets()

  init: ->
    @init_physics()
    @init_graphics()

  init_physics: ->
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

    @rider.init_physics()

  init_graphics: ->
    # Create and add sprites to the scene
    for part in ['body', 'left_wheel', 'right_wheel', 'left_axle', 'right_axle']
      if @ghost
        asset_name = Constants[part].ghost_texture
      else
        asset_name = Constants[part].texture

      @["#{part}_sprite"]       = PIXI.Sprite.from(@assets.get_url(asset_name))
      @["#{part}_sprite"].label = part
      @level.layers.static_level.addChild(@["#{part}_sprite"])

    # Define body values
    @body_sprite.width    = Constants.body.texture_size.x
    @body_sprite.height   = Constants.body.texture_size.y
    @body_sprite.anchor.x = 0.5
    @body_sprite.anchor.y = 0.5

    # Define wheels values
    for wheel_name in ['left_wheel', 'right_wheel']
      @["#{wheel_name}_sprite"].width    = 2 * Constants[wheel_name].radius
      @["#{wheel_name}_sprite"].height   = 2 * Constants[wheel_name].radius
      @["#{wheel_name}_sprite"].anchor.x = 0.5
      @["#{wheel_name}_sprite"].anchor.y = 0.5

    # Define axles values
    for axle_name in ['left_axle', 'right_axle']
      @["#{axle_name}_sprite"].anchor.x = 0.0
      @["#{axle_name}_sprite"].anchor.y = 0.5

    @rider.init_graphics()

  move: (input = @level.input) ->
    moto_acceleration = Constants.moto_acceleration
    biker_force       = Constants.biker_force

    if not @dead
      # Accelerate
      if input.up
        @left_wheel.applyTorque(- @mirror * moto_acceleration)

      # Brakes
      if input.down
        # block wheels
        @right_wheel.setAngularVelocity(0)
        @left_wheel.setAngularVelocity(0)

      # Back wheeling
      if (input.left && @mirror == 1) || (input.right && @mirror == -1)
        @wheeling(biker_force)

      # Front wheeling
      if (input.right && @mirror == 1) || (input.left && @mirror == -1)
        biker_force = -biker_force * 0.8 # a bit less force for front wheeling
        @wheeling(biker_force)

      if input.space
        @flip()

    if !input.up && !input.down
      # Engine brake
      v = @left_wheel.getAngularVelocity()
      @left_wheel.applyTorque((if Math.abs(v) >= 0.2 then -v/10 else 0))

      # Friction on right wheel
      v = @right_wheel.getAngularVelocity()
      @right_wheel.applyTorque((if Math.abs(v) >= 0.2 then -v/100 else 0))

    # Left wheel suspension
    back_force = Constants.left_suspension.back_force
    rigidity   = Constants.left_suspension.rigidity
    @left_prismatic_joint.setMaxMotorForce(rigidity+Math.abs(rigidity*100*Math.pow(@left_prismatic_joint.getJointTranslation(), 2)))
    @left_prismatic_joint.setMotorSpeed(-back_force*@left_prismatic_joint.getJointTranslation())

    # Right wheel suspension
    back_force = Constants.right_suspension.back_force
    rigidity   = Constants.right_suspension.rigidity
    @right_prismatic_joint.setMaxMotorForce(rigidity+Math.abs(rigidity*100*Math.pow(@right_prismatic_joint.getJointTranslation(), 2)))
    @right_prismatic_joint.setMotorSpeed(-back_force*@right_prismatic_joint.getJointTranslation())

    # Drag (air resistance)
    air_density        = Constants.air_density
    object_penetration = 0.025
    squared_speed      = Math.pow(@body.getLinearVelocity().x, 2)
    drag_force         = air_density * squared_speed * object_penetration
    @body.setLinearDamping(drag_force)

    # Limitation of wheel rotation speed (and by extension, of moto)
    if @right_wheel.getAngularVelocity() > Constants.max_moto_speed
      @right_wheel.setAngularVelocity(Constants.max_moto_speed)
    else if @right_wheel.getAngularVelocity() < -Constants.max_moto_speed
      @right_wheel.setAngularVelocity(-Constants.max_moto_speed)

    if @left_wheel.getAngularVelocity() > Constants.max_moto_speed
      @left_wheel.setAngularVelocity(Constants.max_moto_speed)
    else if @left_wheel.getAngularVelocity() < -Constants.max_moto_speed
      @left_wheel.setAngularVelocity(-Constants.max_moto_speed)

    # Detection of drifting
    #rotation_speed = -(moto.left_wheel.getAngularVelocity()*Math.PI/180)*2*Math.PI*Constants.left_wheel.radius
    #linear_speed   = moto.left_wheel.getLinearVelocity().x/10
    #if linear_speed > 0 and rotation_speed > 1.5*linear_speed
    #  @level.particles.create()

  wheeling: (force) ->
    moto_angle = @mirror * @body.getAngle()

    @body.applyTorque(@mirror * force * 0.50)

    force_torso   = Math2D.rotate_point({x: @mirror * (-force), y: 0}, moto_angle, {x: 0, y: 0})
    force_torso.y = @mirror * force_torso.y
    @rider.torso.applyForce(force_torso, @rider.torso.getWorldCenter())

    force_leg   = Math2D.rotate_point({x: @mirror * force, y: 0}, moto_angle, {x: 0, y: 0})
    force_leg.y = @mirror * force_leg.y
    @rider.lower_leg.applyForce(force_leg, @rider.lower_leg.getWorldCenter())

  flip: ->
    if not @dead
      MotoFlipService.execute(this)

  create_body: ->
    shape = new Polygon(Physics.create_shape(Constants.body.vertices, @mirror == -1))

    body = @world.createBody({
      type:     'dynamic'
      position: {
        x: @player_start.x + @mirror * Constants.body.position.x
        y: @player_start.y +           Constants.body.position.y
      }
      userData: {
        name: 'moto'
        type: if @ghost then 'ghost' else 'player'
        moto: this
      }
    })

    body.createFixture(shape, {
      density:          Constants.body.density
      restitution:      Constants.body.restitution
      friction:         Constants.body.friction
      isSensor:         !Constants.body.collisions
      filterGroupIndex: -1
    })

    body

  create_wheel: (part_constants) ->
    shape = new Circle(part_constants.radius)

    wheel = @world.createBody({
      type:     'dynamic'
      position: {
        x: @player_start.x + @mirror * part_constants.position.x
        y: @player_start.y +           part_constants.position.y
      }
      userData: {
        name: 'moto'
        type: if @ghost then 'ghost' else 'player'
        moto: this
      }
    })

    wheel.createFixture(shape, {
      density:          part_constants.density
      restitution:      part_constants.restitution
      friction:         part_constants.friction
      isSensor:         !part_constants.collisions
      filterGroupIndex: -1
    })

    wheel

  create_axle: (part_constants) ->
    shape = new Polygon(Physics.create_shape(part_constants.vertices, @mirror == -1))

    body = @world.createBody({
      type:     'dynamic'
      position: {
        x: @player_start.x + @mirror * part_constants.position.x
        y: @player_start.y +           part_constants.position.y
      }
      userData: {
        name: 'moto'
        type: if @ghost then 'ghost' else 'player'
        moto: this
      }
    })

    body.createFixture(shape, {
      density:          part_constants.density
      restitution:      part_constants.restitution
      friction:         part_constants.friction
      isSensor:         !part_constants.collisions
      filterGroupIndex: -1
    })

    body

  create_revolute_joint: (axle, wheel) ->
    @world.createJoint(new RevoluteJoint({}, axle, wheel, wheel.getWorldCenter()))

  create_prismatic_joint: (axle, part_constants) ->
    angle = part_constants.angle
    axis  = {x: @mirror * angle.x, y: angle.y}

    @world.createJoint(new PrismaticJoint({
      enableLimit:      true
      lowerTranslation: part_constants.lower_translation
      upperTranslation: part_constants.upper_translation
      enableMotor:      true
      collideConnected: false
    }, @body, axle, axle.getWorldCenter(), axis))

  update: ->
    @aabb = @compute_aabb()

    if !Constants.debug_physics
      visible = @visible()

      @update_wheel(     @left_wheel,  Constants.left_wheel,  visible)
      @update_wheel(     @right_wheel, Constants.right_wheel, visible)
      @update_left_axle( @left_axle,   Constants.left_axle,   visible)
      @update_right_axle(@right_axle,  Constants.right_axle,  visible)
      @update_body(      @body,        Constants.body,        visible)

      @rider.update(visible)

  update_wheel: (part, part_constants, visible) ->
    if part_constants.position.x < 0
      wheel_sprite = @left_wheel_sprite
    else
      wheel_sprite = @right_wheel_sprite

    wheel_sprite.visible = visible

    if visible
      position = part.getPosition()
      angle    = part.getAngle()

      wheel_sprite.x        = position.x
      wheel_sprite.y        = -position.y
      wheel_sprite.rotation = -angle
      wheel_sprite.scale.x  = @mirror * Math.abs(wheel_sprite.scale.x)

  update_body: (part, part_constants, visible) ->
    @body_sprite.visible = visible

    if visible
      position = part.getPosition()
      angle    = part.getAngle()

      @body_sprite.x        = position.x
      @body_sprite.y        = -position.y
      @body_sprite.rotation = -angle
      @body_sprite.scale.x  = @mirror * Math.abs(@body_sprite.scale.x)

  update_left_axle: (part, part_constants, visible) ->
    axle_thickness = 0.09

    wheel_position = @left_wheel.getPosition()
    wheel_position =
      x: wheel_position.x - @mirror * axle_thickness/2.0
      y: wheel_position.y - 0.025

    # Position relative to center of body
    axle_position =
      x: -0.17 * @mirror
      y: -0.30

    texture = if @ghost then part_constants.ghost_texture else part_constants.texture
    @update_axle_common(wheel_position, axle_position, axle_thickness, texture, 'left', visible)

  update_right_axle: (part, part_constants, visible) ->
    axle_thickness = 0.07

    wheel_position = @right_wheel.getPosition()
    wheel_position =
      x: wheel_position.x + @mirror * axle_thickness/2.0 - @mirror * 0.03
      y: wheel_position.y - 0.045

    # Position relative to center of body
    axle_position =
      x: 0.52 * @mirror
      y: 0.025

    texture = if @ghost then part_constants.ghost_texture else part_constants.texture
    @update_axle_common(wheel_position, axle_position, axle_thickness, texture, 'right', visible)

  update_axle_common: (wheel_position, axle_position, axle_thickness, texture, side, visible) ->
    axle_sprite = @["#{side}_axle_sprite"]
    axle_sprite.visible = visible

    if visible
      body_position = @body.getPosition()
      body_angle    = @body.getAngle()

      # Adjusted position depending of rotation of body
      axle_adjusted_position = Math2D.rotate_point(axle_position, body_angle, body_position)

      # Distance
      distance = Math2D.distance_between_points(wheel_position, axle_adjusted_position)

      # Angle
      angle = Math2D.angle_between_points(axle_adjusted_position, wheel_position) + @mirror * Math.PI/2

      axle_sprite.width    = distance
      axle_sprite.height   = axle_thickness
      axle_sprite.x        =  wheel_position.x
      axle_sprite.y        = -wheel_position.y
      axle_sprite.rotation = -angle
      axle_sprite.scale.x  = @mirror * Math.abs(axle_sprite.scale.x)

  # estimation of aabb of moto + rider (based on wheels and head)
  compute_aabb: ->
    # lower position of wheels or head (in case or looping)
    lower1 = @left_wheel.getFixtureList().getAABB(0).lowerBound
    lower2 = @right_wheel.getFixtureList().getAABB(0).lowerBound
    lower3 = @rider.head.getFixtureList().getAABB(0).lowerBound

    # upper position of wheels or head (in case or looping)
    upper1 = @left_wheel.getFixtureList().getAABB(0).upperBound
    upper2 = @right_wheel.getFixtureList().getAABB(0).upperBound
    upper3 = @rider.head.getFixtureList().getAABB(0).upperBound

    aabb = new AABB()
    aabb.lowerBound.set(Math.min(lower1.x, lower2.x, lower3.x), Math.min(lower1.y, lower2.y, lower3.y))
    aabb.upperBound.set(Math.max(upper1.x, upper2.x, upper3.x), Math.max(upper1.y, upper2.y, upper3.y))

    return aabb

  visible: ->
    AABB.testOverlap(@aabb, @level.camera.aabb)
