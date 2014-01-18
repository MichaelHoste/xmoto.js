class Replay

  constructor: (level) ->
    @level   = level
    @frames  = []
    @physics = level.physics

  clone: ->
    new_replay = new Replay(@level)
    for frame in @frames
      new_replay.frames.push($.extend(true, {}, frame))
    new_replay

  add_frame: ->
    moto   = @level.moto
    rider  = @level.moto.rider

    frame =
      time:        @level.current_time
      mirror:      moto.mirror == -1  # true if moto is reversed
      left_wheel:  position_2d(moto.left_wheel)
      right_wheel: position_2d(moto.right_wheel)
      body:        position_2d(moto.body)
      torso:       position_2d(moto.rider.torso)
      upper_leg:   position_2d(moto.rider.upper_leg)
      lower_leg:   position_2d(moto.rider.lower_leg)
      upper_arm:   position_2d(moto.rider.upper_arm)
      lower_arm:   position_2d(moto.rider.lower_arm)

    @frames.push(frame)

  frames_count: ->
    @frames.length

  frame: (number) ->
    if number < @frames_count()
      @frames[number]
    else
      @frame(@frames_count() - 1)

  current_frame: ->
    ratio_fps     = Constants.fps / Constants.replay_fps
    frame_number  = Math.floor(@physics.steps / ratio_fps)
    interpolation =            @physics.steps % ratio_fps
    current_frame = @frame(frame_number)
    next_frame    = @frame(frame_number + 1)
    @interpolate_frames(current_frame, next_frame, interpolation)

  interpolate_frames: (current_frame, next_frame, interpolation) ->
    frame =
      time:        current_frame.time
      mirror:      current_frame.mirror
      left_wheel:  interpolate_position_2d(current_frame.left_wheel,  next_frame.left_wheel,  interpolation)
      right_wheel: interpolate_position_2d(current_frame.right_wheel, next_frame.right_wheel, interpolation)
      body:        interpolate_position_2d(current_frame.body,        next_frame.body,        interpolation)
      torso:       interpolate_position_2d(current_frame.torso,       next_frame.torso,       interpolation)
      upper_leg:   interpolate_position_2d(current_frame.upper_leg,   next_frame.upper_leg,   interpolation)
      lower_leg:   interpolate_position_2d(current_frame.lower_leg,   next_frame.lower_leg,   interpolation)
      upper_arm:   interpolate_position_2d(current_frame.upper_arm,   next_frame.upper_arm,   interpolation)
      lower_arm:   interpolate_position_2d(current_frame.lower_arm,   next_frame.lower_arm,   interpolation)

position_2d = (object) ->
  position:
    x:   object.GetPosition().x
    y:   object.GetPosition().y
  angle: object.GetAngle()

interpolate_position_2d = (part_1, part_2, interpolation) ->
  ratio_fps    = Constants.fps / Constants.replay_fps
  part_1_ratio = (ratio_fps - interpolation) / ratio_fps
  part_2_ratio = interpolation               / ratio_fps

  return {
    position:
      x:   part_1.position.x * part_1_ratio + part_2.position.x * part_2_ratio
      y:   part_1.position.y * part_1_ratio + part_2.position.y * part_2_ratio
    angle: part_1.angle      * part_1_ratio + part_2.angle      * part_2_ratio
  }
