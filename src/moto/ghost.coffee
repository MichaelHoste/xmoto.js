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


      @current_frame = @current_frame + 1

  init: ->
    # Assets
    textures = [ @rider_style.torso,    @rider_style.upperleg, @rider_style.lowerleg
                 @rider_style.upperarm, @rider_style.lowerarm
                 @rider_style.body,     @rider_style.wheel
                 @rider_style.front,    @rider_style.rear ]
    for texture in textures
      @assets.moto.push(texture)




