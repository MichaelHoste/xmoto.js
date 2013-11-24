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
    if @replay
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
    if @level.get_render_mode() == "normal" or @level.get_render_mode() == "uglyOver"
      @display_normal_part(@frame.anchors.hip, @frame.anchors.shoulder, @assets.get('playertorso'), @mirror, -0.27, -0.80, 0.5, 1.15)

    if @level.get_render_mode() == "ugly" or @level.get_render_mode() == "uglyOver"
      @level.ctx.beginPath()
      @level.ctx.strokeStyle="#00FF00"
      @level.ctx.lineWidth = 0.05
      frame = @replay.frame(@current_frame)
      @level.ctx.moveTo(frame.anchors.shoulder.x, frame.anchors.shoulder.y)
      @level.ctx.lineTo(frame.anchors.hip.x, frame.anchors.hip.y)
      @level.ctx.stroke()

      @level.ctx.beginPath()
      @level.ctx.strokeStyle="#00FF00"
      @level.ctx.lineWidth = 0.05
      @level.ctx.arc(frame.anchors.neck.x, frame.anchors.neck.y, Constants.cpp.rider_head_size, 0, 2*Math.PI)
      @level.ctx.stroke()

  display_lower_leg: ->
    if @level.get_render_mode() == "normal" or @level.get_render_mode() == "uglyOver"
      @display_normal_part(@frame.anchors.ankle, @frame.anchors.knee, @assets.get('playerlowerleg'), @mirror, -0.17, -0.33, 0.40, 0.66)

    if @level.get_render_mode() == "ugly" or @level.get_render_mode() == "uglyOver"
      @level.ctx.beginPath()
      @level.ctx.strokeStyle="#00FF00"
      @level.ctx.lineWidth = 0.05
      frame = @replay.frame(@current_frame)
      @level.ctx.moveTo(frame.anchors.ankle.x, frame.anchors.ankle.y)
      @level.ctx.lineTo(frame.anchors.knee.x, frame.anchors.knee.y)
      @level.ctx.stroke()

  display_upper_leg: ->
    if @level.get_render_mode() == "normal" or @level.get_render_mode() == "uglyOver"
      @display_normal_part(@frame.anchors.hip, @frame.anchors.knee, @assets.get('playerupperleg'), @mirror, -0.48, -0.15, 0.80, 0.28, 1)

    if @level.get_render_mode() == "ugly" or @level.get_render_mode() == "uglyOver"
      @level.ctx.beginPath()
      @level.ctx.strokeStyle="#00FF00"
      @level.ctx.lineWidth = 0.05
      frame = @replay.frame(@current_frame)
      @level.ctx.moveTo(frame.anchors.hip.x, frame.anchors.hip.y)
      @level.ctx.lineTo(frame.anchors.knee.x, frame.anchors.knee.y)
      @level.ctx.stroke()

  display_lower_arm: ->
    # Draw texture
    if @level.get_render_mode() == "normal" or @level.get_render_mode() == "uglyOver"
      @display_normal_part(@frame.anchors.elbow, @frame.anchors.wrist, @assets.get('playerlowerarm'), -@mirror, -0.30, -0.12, 0.56, 0.20, 1)

    if @level.get_render_mode() == "ugly" or @level.get_render_mode() == "uglyOver"
      @level.ctx.beginPath()
      @level.ctx.strokeStyle="#00FF00"
      @level.ctx.lineWidth = 0.05
      frame = @replay.frame(@current_frame)
      @level.ctx.moveTo(frame.anchors.elbow.x, frame.anchors.elbow.y)
      @level.ctx.lineTo(frame.anchors.wrist.x, frame.anchors.wrist.y)
      @level.ctx.stroke()

  display_upper_arm: ->
    if @level.get_render_mode() == "normal" or @level.get_render_mode() == "uglyOver"
      @display_normal_part(@frame.anchors.elbow, @frame.anchors.shoulder, @assets.get('playerupperarm'), -@mirror, -0.13, -0.3, 0.25, 0.56)

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

  pointsToAngle: (a, b) ->
    if a.y > b.y
      return -Math.atan((a.x-b.x)/(a.y-b.y))
    else
      return -Math.atan((b.x-a.x)/(b.y-a.y)) + Math.PI

  display_normal_part: (anchor1, anchor2, texture, mirror, x, y, sx, sy, i90rot = 0) ->
    @level.ctx.save()
    centerX = (anchor1.x + anchor2.x)/2
    centerY = (anchor1.y + anchor2.y)/2
    angle   = @pointsToAngle(anchor1, anchor2) + mirror*i90rot*Math.PI/2.0
    @level.ctx.translate(centerX, centerY)
    @level.ctx.scale(-mirror, 1)
    @level.ctx.rotate(-mirror * angle)
    @level.ctx.drawImage(texture, x, y, sx, sy)
    @level.ctx.restore()
