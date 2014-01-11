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
      Moto.display_wheel(@level, @frame.left_wheel,  Constants.left_wheel,  @mirror, 'ghost_')
      Moto.display_wheel(@level, @frame.right_wheel, Constants.right_wheel, @mirror, 'ghost_')
      #Moto.display_left_axle()
      #Moto.display_right_axle()
      Moto.display_body( @level, @frame.body,        Constants.body,        @mirror, 'ghost_')

      Rider.display_part(@level, @frame.torso,     Constants.torso,     @mirror, 'ghost_')
      Rider.display_part(@level, @frame.upper_leg, Constants.upper_leg, @mirror, 'ghost_')
      Rider.display_part(@level, @frame.lower_leg, Constants.lower_leg, @mirror, 'ghost_')
      Rider.display_part(@level, @frame.upper_arm, Constants.upper_arm, @mirror, 'ghost_')
      Rider.display_part(@level, @frame.lower_arm, Constants.lower_arm, @mirror, 'ghost_')

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
    parts = [ Constants.torso, Constants.upper_leg, Constants.lower_leg,
              Constants.upper_arm, Constants.lower_arm,
              Constants.body, Constants.left_wheel, Constants.right_wheel,
              Constants.left_axle, Constants.left_axle ]
    for part in parts
      @assets.moto.push(part.ghost_texture)
