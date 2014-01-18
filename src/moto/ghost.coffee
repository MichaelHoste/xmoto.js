class Ghost

  constructor: (level, replay) ->
    @level   = level
    @assets  = level.assets
    @replay  = replay
    @physics = level.physics

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

  init: ->
    # Assets
    parts = [ Constants.torso, Constants.upper_leg, Constants.lower_leg,
              Constants.upper_arm, Constants.lower_arm,
              Constants.body, Constants.left_wheel, Constants.right_wheel,
              Constants.left_axle, Constants.right_axle ]
    for part in parts
      @assets.moto.push(part.ghost_texture)

  current_frame: ->
    @replay.current_frame()
