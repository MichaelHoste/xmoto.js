class Ghost

  constructor: (level, replay) ->
    @level  = level
    @assets = level.assets

  display: ->
    @display_wheel(@left_wheel)
    @display_wheel(@right_wheel)
    @display_left_axle()
    @display_right_axle()
    @display_body()
    @rider.display()

  init: ->
    # Assets
    textures = [ 'front1', 'lowerarm1', 'lowerleg1', 'ghostbikerbody',
                 'ghostbikerwheel', 'rear1',
                 'ghostlowerarm', 'ghostlowerleg', 'ghosttorso',
                 'ghostupperarm', 'ghostupperleg', 'rear1' ]
    for texture in textures
      @assets.moto.push(texture)

    # Creation of moto parts
    @player_start = @level.entities.player_start
    @body         = @create_body(@player_start.x, @player_start.y + 1.0)

    @left_wheel   = @create_wheel(@player_start.x - 0.7, @player_start.y + 0.48)
    @right_wheel  = @create_wheel(@player_start.x + 0.7, @player_start.y + 0.48)

    @left_axle    = @create_left_axle( @player_start.x, @player_start.y + 1.0)
    @right_axle   = @create_right_axle(@player_start.x, @player_start.y + 1.0)

    @left_revolute_joint  = @create_left_revolute_joint()
    @left_prismatic_joint = @create_left_prismatic_joint()

    @right_revolute_joint  = @create_right_revolute_joint()
    @right_prismatic_joint = @create_right_prismatic_joint()

    @rider.init()

  position: ->
    @body.GetPosition()

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
      -radius,   # x
      -radius,   # y
       radius*2, # size-x
       radius*2  # size-y
    )

    @level.ctx.restore()

  display_body: ->
    # Position
    position = @position()

    # Angle
    angle = @body.GetAngle()

    # Draw texture
    @level.ctx.save()
    @level.ctx.translate(position.x, position.y)
    @level.ctx.scale(1, -1)
    @level.ctx.rotate(-angle)

    @level.ctx.drawImage(
      @assets.get('playerbikerbody'), # texture
      -1.0, # x
      -0.5, # y
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
    left_axle_adjusted_position = Math2D.rotate_point(left_axle_position, @body.GetAngle(), @position())

    # Distance
    distance = Math2D.distance_between_points(left_wheel_position, left_axle_adjusted_position)

    # Angle
    angle = Math2D.angle_between_points(left_axle_adjusted_position, left_wheel_position) + Math.PI/2

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
    right_axle_adjusted_position = Math2D.rotate_point(right_axle_position, @body.GetAngle(), @position())

    # Distance
    distance = Math2D.distance_between_points(right_wheel_position, right_axle_adjusted_position)

    # Angle
    angle = Math2D.angle_between_points(right_axle_adjusted_position, right_wheel_position) + Math.PI/2

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
