class Ghost

  constructor: (level, replay, style = "ghost") ->
    @level  = level
    @assets = level.assets
    @replay = replay
    @current_frame = 0
    @rider_style = @assets.get_rider_style(style)

  display: ->
    if @replay and @current_frame < @replay.frames_count()
      @frame = @replay.frame(@current_frame)

      @mirror = if @frame.mirror then -1 else 1
      Rider.display_rider(@mirror,
                          @frame.anchors.wrist,
                          @frame.anchors.elbow
                          @frame.anchors.shoulder
                          @frame.anchors.hip
                          @frame.anchors.knee
                          @frame.anchors.ankle
                          @level.ctx, @level.assets, @rider_style, @level.get_render_mode())
      Moto.display_moto(@mirror,
                        @frame.left_wheel.position,
                        @frame.left_wheel.angle,
                        @frame.right_wheel.position,
                        @frame.right_wheel.angle,
                        @frame.body.position,
                        @frame.body.angle
                        @level.ctx, @level.assets, @rider_style, @level.get_render_mode())

  rewind: (x) ->
    @current_frame = 0
    @next_state() # find the next correct state

  next_state: ->
    if @replay
      gameTime = @level.gameTime()
      find_next_frame = true
      while find_next_frame
        # if no more frame, don't continue
        if @current_frame >= @replay.frames_count()-1
          find_next_frame = false
        else
          next_current_frame_n = @current_frame + 1
          next_current_frame   = @replay.frame(next_current_frame_n)
          # next frame is in the future, don't continue
          if next_current_frame.gameTime*100 >= gameTime
            find_next_frame = false
          else
            @current_frame = next_current_frame_n

  init: ->
    # Assets
    textures = [ @rider_style.torso,    @rider_style.upperleg, @rider_style.lowerleg
                 @rider_style.upperarm, @rider_style.lowerarm
                 @rider_style.body,     @rider_style.wheel
                 @rider_style.front,    @rider_style.rear ]
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

  position: ->
    @replay.frame(@current_frame).body.position
