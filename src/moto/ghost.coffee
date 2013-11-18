class Ghost

  constructor: (level, replay) ->
    @level  = level
    @assets = level.assets
    @replay = replay
    @current_frame = 0

  display: ->
    if @replay and @current_frame < @replay.frames_count()
      @frame = @replay.frame(@current_frame)
      @mirror = if @frame.mirror then -1 else 1

      @display_left_wheel()
      @display_right_wheel()
      @display_body()
      @display_torso()
      @display_upper_leg()
      @display_lower_leg()
      @display_upper_arm()
      @display_lower_arm()

  next_state: ->
    if @current_frame < @replay.frames_count()-1
      @current_frame = @current_frame + 1

  init: ->
    # Assets
    textures = [ 'playerbikerbody', 'playerbikerwheel', 'front1', 'rear1'
                 'playerlowerarm', 'playerlowerleg', 'playertorso',
                 'playerupperarm', 'playerupperleg' ]
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

    if @level.get_render_mode() == "normal" or @level.get_render_mode() == "uglyOver"
      @level.ctx.drawImage(
        @assets.get('playerbikerwheel'), # texture
        -radius,   # x
        -radius,   # y
         radius*2, # size-x
         radius*2  # size-y
      )
    if @level.get_render_mode() == "ugly" or @level.get_render_mode() == "uglyOver"
      @level.ctx.beginPath()
      @level.ctx.strokeStyle="#FF0000"
      @level.ctx.lineWidth = 0.05
      @level.ctx.arc(0, 0, radius, 0, 2*Math.PI)
      @level.ctx.stroke()

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

    if @level.get_render_mode() == "normal" or @level.get_render_mode() == "uglyOver"
      @level.ctx.drawImage(
        @assets.get('playerbikerwheel'), # texture
        -radius,   # x
        -radius,   # y
         radius*2, # size-x
         radius*2  # size-y
      )
    if @level.get_render_mode() == "ugly" or @level.get_render_mode() == "uglyOver"
      @level.ctx.beginPath()
      @level.ctx.strokeStyle="#FF0000"
      @level.ctx.lineWidth = 0.05
      @level.ctx.arc(0, 0, radius, 0, 2*Math.PI)
      @level.ctx.stroke()

    @level.ctx.restore()

  display_body: ->
    body = @frame.body

    # Position
    position = body.position

    # Angle
    angle = body.angle

    # Draw texture
    if @level.get_render_mode() == "normal" or @level.get_render_mode() == "uglyOver"
      @level.ctx.save()
      @level.ctx.translate(position.x, position.y)
      @level.ctx.scale(1*@mirror, -1)
      @level.ctx.rotate(@mirror * (-angle))

      @level.ctx.drawImage(
        @assets.get('playerbikerbody'), # texture
        -1.0, # x
        -0.5, # y
         2.0, # size-x
         1.0  # size-y
      )

      @level.ctx.restore()

  display_torso: ->
    torso = @frame.torso

    # Position
    position = torso.position

    # Angle
    angle = torso.angle

    # Draw texture
    if @level.get_render_mode() == "normal" or @level.get_render_mode() == "uglyOver"
      @level.ctx.save()
      @level.ctx.translate(position.x, position.y)
      @level.ctx.scale(1*@mirror, -1)
      @level.ctx.rotate(@mirror * (-angle))

      @level.ctx.drawImage(
        @assets.get('playertorso'), # texture
        -0.25,  # x
        -0.575, # y
         0.5,   # size-x
         1.15   # size-y
      )

      @level.ctx.restore()

    if @level.get_render_mode() == "ugly" or @level.get_render_mode() == "uglyOver"
      @level.ctx.beginPath()
      @level.ctx.strokeStyle="#00FF00"
      @level.ctx.lineWidth = 0.05
      frame = @replay.frame(@current_frame)
      @level.ctx.moveTo(frame.anchors.shoulder.x, frame.anchors.shoulder.y)
      @level.ctx.lineTo(frame.anchors.lowerBody.x, frame.anchors.lowerBody.y)
      @level.ctx.stroke()

      @level.ctx.beginPath()
      @level.ctx.strokeStyle="#00FF00"
      @level.ctx.lineWidth = 0.05
      @level.ctx.arc(frame.anchors.head.x, frame.anchors.head.y, 0.22, 0, 2*Math.PI)
      @level.ctx.stroke()

  display_lower_leg: ->
    lower_leg = @frame.lower_leg

    # Position
    position = lower_leg.position

    # Angle
    angle = lower_leg.angle

    # Draw texture
    if @level.get_render_mode() == "normal" or @level.get_render_mode() == "uglyOver"
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

    if @level.get_render_mode() == "ugly" or @level.get_render_mode() == "uglyOver"
      @level.ctx.beginPath()
      @level.ctx.strokeStyle="#00FF00"
      @level.ctx.lineWidth = 0.05
      frame = @replay.frame(@current_frame)
      @level.ctx.moveTo(frame.anchors.foot.x, frame.anchors.foot.y)
      @level.ctx.lineTo(frame.anchors.knee.x, frame.anchors.knee.y)
      @level.ctx.stroke()

  display_upper_leg: ->
    upper_leg = @frame.upper_leg

    # Position
    position = upper_leg.position

    # Angle
    angle = upper_leg.angle

    # Draw texture
    if @level.get_render_mode() == "normal" or @level.get_render_mode() == "uglyOver"
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

    if @level.get_render_mode() == "ugly" or @level.get_render_mode() == "uglyOver"
      @level.ctx.beginPath()
      @level.ctx.strokeStyle="#00FF00"
      @level.ctx.lineWidth = 0.05
      frame = @replay.frame(@current_frame)
      @level.ctx.moveTo(frame.anchors.lowerBody.x, frame.anchors.lowerBody.y)
      @level.ctx.lineTo(frame.anchors.knee.x, frame.anchors.knee.y)
      @level.ctx.stroke()

  display_lower_arm: ->
    lower_arm = @frame.lower_arm

    # Position
    position = lower_arm.position

    # Angle
    angle = lower_arm.angle

    # Draw texture
    if @level.get_render_mode() == "normal" or @level.get_render_mode() == "uglyOver"
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

    if @level.get_render_mode() == "ugly" or @level.get_render_mode() == "uglyOver"
      @level.ctx.beginPath()
      @level.ctx.strokeStyle="#00FF00"
      @level.ctx.lineWidth = 0.05
      frame = @replay.frame(@current_frame)
      @level.ctx.moveTo(frame.anchors.elbow.x, frame.anchors.elbow.y)
      @level.ctx.lineTo(frame.anchors.hand.x, frame.anchors.hand.y)
      @level.ctx.stroke()

  display_upper_arm: ->
    upper_arm = @frame.upper_arm

    # Position
    position = upper_arm.position

    # Angle
    angle = upper_arm.angle

    # Draw texture
    if @level.get_render_mode() == "normal" or @level.get_render_mode() == "uglyOver"
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

    if @level.get_render_mode() == "ugly" or @level.get_render_mode() == "uglyOver"
      @level.ctx.beginPath()
      @level.ctx.strokeStyle="#00FF00"
      @level.ctx.lineWidth = 0.05
      frame = @replay.frame(@current_frame)
      @level.ctx.moveTo(frame.anchors.shoulder.x, frame.anchors.shoulder.y)
      @level.ctx.lineTo(frame.anchors.elbow.x, frame.anchors.elbow.y)
      @level.ctx.stroke()

  position: ->
    @replay.frame(@current_frame).body.position
