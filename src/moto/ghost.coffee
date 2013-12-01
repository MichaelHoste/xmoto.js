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
                          @frame.anchors.neck,
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

  forward: (x) ->
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

  position: ->
    @replay.frame(@current_frame).body.position
