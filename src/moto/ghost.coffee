class Ghost

  constructor: (level, replay) ->
    @level   = level
    @replay  = replay
    @moto    = new Moto(@level)

  init: ->
    @moto.init()

  move: ->
    current_input =
      up:    @replay.is_down('up')
      down:  @replay.is_down('down')
      left:  @replay.is_down('left')
      right: @replay.is_down('right')

    @moto.move(current_input)

  display: (transparent = true) ->
    @moto.display()
    #if @replay and !Constants.debug
    #  @frame         = @current_frame()
    #  mirror         = if @frame.mirror then -1       else 1
    #  texture_prefix = if transparent   then 'ghost_' else ''
#
    #  Moto.display_wheel(     @level, @frame.left_wheel,  Constants.left_wheel,  mirror,                                  texture_prefix)
    #  Moto.display_wheel(     @level, @frame.right_wheel, Constants.right_wheel, mirror,                                  texture_prefix)
    #  Moto.display_left_axle( @level, @frame.left_axle,   Constants.left_axle,   @frame.body, @frame.left_wheel,  mirror, texture_prefix)
    #  Moto.display_right_axle(@level, @frame.right_axle,  Constants.right_axle,  @frame.body, @frame.right_wheel, mirror, texture_prefix)
    #  Moto.display_body(      @level, @frame.body,        Constants.body,        mirror,                                  texture_prefix)
#
    #  Rider.display_part(@level, @frame.torso,     Constants.torso,     mirror, texture_prefix)
    #  Rider.display_part(@level, @frame.upper_leg, Constants.upper_leg, mirror, texture_prefix)
    #  Rider.display_part(@level, @frame.lower_leg, Constants.lower_leg, mirror, texture_prefix)
    #  Rider.display_part(@level, @frame.upper_arm, Constants.upper_arm, mirror, texture_prefix)
    #  Rider.display_part(@level, @frame.lower_arm, Constants.lower_arm, mirror, texture_prefix)

