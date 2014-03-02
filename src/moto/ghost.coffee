class Ghost

  constructor: (level, replay) ->
    @level   = level
    @replay  = replay

  display: ->
    if @replay
      @frame = @current_frame()
      mirror = if @frame.mirror then -1 else 1

      Moto.display_wheel(     @level, @frame.left_wheel,  Constants.left_wheel,  mirror,                                  'ghost_')
      Moto.display_wheel(     @level, @frame.right_wheel, Constants.right_wheel, mirror,                                  'ghost_')
      Moto.display_left_axle( @level, @frame.left_axle,   Constants.left_axle,   @frame.body, @frame.left_wheel,  mirror, 'ghost_')
      Moto.display_right_axle(@level, @frame.right_axle,  Constants.right_axle,  @frame.body, @frame.right_wheel, mirror, 'ghost_')
      Moto.display_body(      @level, @frame.body,        Constants.body,        mirror,                                  'ghost_')

      Rider.display_part(@level, @frame.torso,     Constants.torso,     mirror, 'ghost_')
      Rider.display_part(@level, @frame.upper_leg, Constants.upper_leg, mirror, 'ghost_')
      Rider.display_part(@level, @frame.lower_leg, Constants.lower_leg, mirror, 'ghost_')
      Rider.display_part(@level, @frame.upper_arm, Constants.upper_arm, mirror, 'ghost_')
      Rider.display_part(@level, @frame.lower_arm, Constants.lower_arm, mirror, 'ghost_')

  current_frame: ->
    @replay.current_frame()
