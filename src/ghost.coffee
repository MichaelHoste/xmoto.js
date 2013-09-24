class Ghost

  constructor: (level, replay) ->
    @level  = level
    @assets = level.assets
    @replay = replay
    @current_frame = 0

  display: ->
    if @replay and @current_frame < @replay.frames_count()
      @frame = @replay.frame(@current_frame)

      @display_left_wheel()
      @display_right_wheel()
      #@display_left_axle()
      #@display_right_axle()
      @display_body()
      @display_torso()
      @display_upper_leg()
      @display_lower_leg()
      @display_upper_arm()
      @display_lower_arm()

      @current_frame = @current_frame + 1

  init: ->
    # Assets
    textures = [ 'ghostbikerbody', 'ghostbikerwheel', 'front_ghost', 'rear_ghost'
                 'ghostlowerarm', 'ghostlowerleg', 'ghosttorso',
                 'ghostupperarm', 'ghostupperleg' ]
    for texture in textures
      @assets.moto.push(texture)

  display_left_wheel: ->
    radius = 0.35
    left_wheel = @frame.left_wheel

    # Position
    position = left_wheel.position

    # Angle
    angle = left_wheel.angle

    # Draw texture
    @level.ctx.save()
    @level.ctx.translate(position.x, position.y)
    @level.ctx.rotate(angle)

    @level.ctx.drawImage(
      @assets.get('ghostbikerwheel'), # texture
      -radius,   # x
      -radius,   # y
       radius*2, # size-x
       radius*2  # size-y
    )

    @level.ctx.restore()

  display_right_wheel: ->
    radius = 0.35
    right_wheel = @frame.right_wheel

    # Position
    position = right_wheel.position

    # Angle
    angle = right_wheel.angle

    # Draw texture
    @level.ctx.save()
    @level.ctx.translate(position.x, position.y)
    @level.ctx.rotate(angle)

    @level.ctx.drawImage(
      @assets.get('ghostbikerwheel'), # texture
      -radius,   # x
      -radius,   # y
       radius*2, # size-x
       radius*2  # size-y
    )

    @level.ctx.restore()

  display_body: ->
    body = @frame.body

    # Position
    position = body.position

    # Angle
    angle = body.angle

    # Draw texture
    @level.ctx.save()
    @level.ctx.translate(position.x, position.y)
    @level.ctx.scale(1, -1)
    @level.ctx.rotate(-angle)

    @level.ctx.drawImage(
      @assets.get('ghostbikerbody'), # texture
      -1.0, # x
      -0.5, # y
       2.0, # size-x
       1.0  # size-y
    )

    @level.ctx.restore()

  display_left_axle: ->
    axle_thickness = 0.09
    left_axle = @frame.left_axle

    # Position
    position = left_axle.position

    # Angle
    angle = left_axle.angle

    # Draw texture
    @level.ctx.save()
    @level.ctx.translate(position.x, position.y)
    @level.ctx.scale(1, -1)
    @level.ctx.rotate(-angle)

    @level.ctx.drawImage(
      @assets.get('rear_ghost'), # texture
      0.0,               # x
      -axle_thickness/2, # y
      distance,          # size-x
      axle_thickness     # size-y
    )

    @level.ctx.restore()

  display_right_axle: ->
    axle_thickness = 0.09
    left_axle = @frame.right_axle

    # Position
    position = right_axle.position

    # Angle
    angle = right_axle.angle

    # Draw texture
    @level.ctx.save()
    @level.ctx.translate(position.x, position.y)
    @level.ctx.scale(1, -1)
    @level.ctx.rotate(-angle)

    @level.ctx.drawImage(
      @assets.get('front_ghost'), # texture
      0.0,               # x
      -axle_thickness/2, # y
      distance,          # size-x
      axle_thickness     # size-y
    )

    @level.ctx.restore()

  display_torso: ->
    torso = @frame.torso

    # Position
    position = torso.position

    # Angle
    angle = torso.angle

    # Draw texture
    @level.ctx.save()
    @level.ctx.translate(position.x, position.y)
    @level.ctx.scale(1, -1)
    @level.ctx.rotate(-angle)

    @level.ctx.drawImage(
      @assets.get('ghosttorso'), # texture
      -0.25,  # x
      -0.575, # y
       0.5,   # size-x
       1.15   # size-y
    )

    @level.ctx.restore()

  display_lower_leg: ->
    lower_leg = @frame.lower_leg

    # Position
    position = lower_leg.position

    # Angle
    angle = lower_leg.angle

    # Draw texture
    @level.ctx.save()
    @level.ctx.translate(position.x, position.y)
    @level.ctx.scale(1, -1)
    @level.ctx.rotate(-angle)

    @level.ctx.drawImage(
      @assets.get('ghostlowerleg'), # texture
      -0.2,  # x
      -0.33, # y
       0.40, # size-x
       0.66  # size-y
    )

    @level.ctx.restore()

  display_upper_leg: ->
    upper_leg = @frame.upper_leg

    # Position
    position = upper_leg.position

    # Angle
    angle = upper_leg.angle

    # Draw texture
    @level.ctx.save()
    @level.ctx.translate(position.x, position.y)
    @level.ctx.scale(1, -1)
    @level.ctx.rotate(-angle)

    @level.ctx.drawImage(
      @assets.get('ghostupperleg'), # texture
      -0.40, # x
      -0.14, # y
       0.80, # size-x
       0.28  # size-y
    )

    @level.ctx.restore()

  display_lower_arm: ->
    lower_arm = @frame.lower_arm

    # Position
    position = lower_arm.position

    # Angle
    angle = lower_arm.angle

    # Draw texture
    @level.ctx.save()
    @level.ctx.translate(position.x, position.y)
    @level.ctx.scale(1, 1)
    @level.ctx.rotate(angle)

    @level.ctx.drawImage(
      @assets.get('ghostlowerarm'), # texture
      -0.28,  # x
      -0.10, # y
       0.56, # size-x
       0.20  # size-y
    )

    @level.ctx.restore()

  display_upper_arm: ->
    upper_arm = @frame.upper_arm

    # Position
    position = upper_arm.position

    # Angle
    angle = upper_arm.angle

    # Draw texture
    @level.ctx.save()
    @level.ctx.translate(position.x, position.y)
    @level.ctx.scale(1, -1)
    @level.ctx.rotate(-angle)

    @level.ctx.drawImage(
      @assets.get('ghostupperarm'), # texture
      -0.125, # x
      -0.28, # y
       0.25, # size-x
       0.56  # size-y
    )

    @level.ctx.restore()
