Circle        = planck.Circle
Polygon       = planck.Polygon
RevoluteJoint = planck.RevoluteJoint

class Rider

  constructor: (level, moto) ->
    @level  = level
    @assets = level.assets
    @world  = level.physics.world
    @moto   = moto
    @mirror = moto.mirror
    @ghost  = moto.ghost

  destroy: ->
    @world.destroyBody(@head)
    @world.destroyBody(@torso)
    @world.destroyBody(@lower_leg)
    @world.destroyBody(@upper_leg)
    @world.destroyBody(@lower_arm)
    @world.destroyBody(@upper_arm)

    @level.layers.static_level.removeChild(@head_sprite)
    @level.layers.static_level.removeChild(@torso_sprite)
    @level.layers.static_level.removeChild(@lower_leg_sprite)
    @level.layers.static_level.removeChild(@upper_leg_sprite)
    @level.layers.static_level.removeChild(@lower_arm_sprite)
    @level.layers.static_level.removeChild(@upper_arm_sprite)

  load_assets: ->
    parts = [ Constants.torso, Constants.upper_leg, Constants.lower_leg,
              Constants.upper_arm, Constants.lower_arm ]
    for part in parts
      if @ghost
        @assets.moto.push(part.ghost_texture)
      else
        @assets.moto.push(part.texture)

  init_physics: ->
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

  init_graphics: ->
    for part in ['torso', 'upper_leg', 'lower_leg', 'upper_arm', 'lower_arm']
      if @ghost
        asset_name = Constants[part].ghost_texture
      else
        asset_name = Constants[part].texture

      @["#{part}_sprite"] = PIXI.Sprite.from(@assets.get_url(asset_name))
      @["#{part}_sprite"].width    = Constants[part].texture_size.x
      @["#{part}_sprite"].height   = Constants[part].texture_size.y
      @["#{part}_sprite"].anchor.x = 0.5
      @["#{part}_sprite"].anchor.y = 0.5
      @["#{part}_sprite"].label    = part

      @level.layers.static_level.addChild(@["#{part}_sprite"])

  position: ->
    @moto.body.getPosition()

  eject: ->
    if !@moto.dead
      @level.listeners.kill_moto(@moto)

      force_vector          = { x: 150.0 * @moto.mirror, y: 0 }
      eject_angle           = @mirror * @moto.body.getAngle() + Math.PI/4.0
      adjusted_force_vector = Math2D.rotate_point(force_vector, eject_angle, {x: 0, y: 0})
      @torso.applyForce(adjusted_force_vector, @torso.getWorldCenter())

  create_head: ->
    shape = new Circle(Constants.head.radius)

    body = @world.createBody(
      type: 'dynamic'
      position:
        x: @player_start.x + @mirror * Constants.head.position.x
        y: @player_start.y +           Constants.head.position.y
      userData:
        name:  'rider'
        type:  if @ghost then 'ghost' else 'player'
        part:  'head'
        rider: this
    )

    body.createFixture(shape,
      density:          Constants.head.density
      restitution:      Constants.head.restitution
      friction:         Constants.head.friction
      isSensor:         !Constants.head.collisions
      filterGroupIndex: -1
    )

    body

  create_part: (part_constants, name) ->
    vertices = Physics.create_shape(part_constants.vertices, @mirror == -1)
    shape    = new Polygon(vertices)

    body = @world.createBody(
      type: 'dynamic'
      position:
        x: @player_start.x + @mirror * part_constants.position.x
        y: @player_start.y +           part_constants.position.y
      angle: @mirror * part_constants.angle
      userData:
        name:  'rider'
        type:  if @ghost then 'ghost' else 'player'
        part:  name
        rider: this
    )

    body.createFixture(shape,
      density:          part_constants.density
      restitution:      part_constants.restitution
      friction:         part_constants.friction
      isSensor:         !part_constants.collisions
      filterGroupIndex: -1
    )

    body

  create_neck_joint: ->
    position = @head.getWorldCenter()

    axe =
      x: position.x
      y: position.y

    opts = {}

    joint = new RevoluteJoint(opts, @head, @torso, axe)

    @world.createJoint(joint)

  create_joint: (joint_constants, part1, part2, invert_joint=false) ->
    position = part1.getWorldCenter()

    axe =
      x: position.x + @mirror * joint_constants.axe_position.x
      y: position.y +           joint_constants.axe_position.y

    opts =
      enableLimit: true
      lowerAngle:  if @mirror == 1 then -Math.PI/15  else -Math.PI/108
      upperAngle:  if @mirror == 1 then  Math.PI/108 else  Math.PI/15

    if invert_joint
      joint = new RevoluteJoint(opts, part2, part1, axe)
    else
      joint = new RevoluteJoint(opts, part1, part2, axe)

    @world.createJoint(joint)

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
      position = part.getPosition()
      angle    = part.getAngle()

      sprite.x        =  position.x
      sprite.y        = -position.y
      sprite.rotation = -angle
      sprite.scale.x  = @mirror * Math.abs(sprite.scale.x)
