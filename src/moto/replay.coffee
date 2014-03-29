class Replay

  constructor: (level) ->
    @level   = level
    @frames  = []
    @physics = level.physics
    @success = false
    @steps   = 0

  clone: ->
    new_replay = new Replay(@level)
    for frame in @frames
      new_replay.frames.push($.extend(true, {}, frame))
    new_replay.success = @success
    new_replay.steps   = @steps
    return new_replay

  load: ->
    options      = @level.options
    selector     = $(options.current_user)
    replay_id    = selector.attr(options.replay_id_attribute)
    replay_steps = selector.attr(options.replay_steps_attribute)
    if selector.length && replay_id.length > 0
      $.get("#{options.replays_path}/#{replay_id}.replay", (data) =>
        @frames  = ReplayConversionService.string_to_frames(data)
        @success = true
        @steps   = parseInt(replay_steps)
      )
      return this
    else
      return null

  save: ->
    $.post(@level.options.scores_path,
      level:  @level.infos.identifier
      time:   @level.current_time
      steps:  @steps
      fps:    Constants.replay_fps
      replay: ReplayConversionService.frames_to_string(@frames)
    )

  add_frame: ->
    moto   = @level.moto
    rider  = @level.moto.rider

    frame =
      #time:        @level.current_time
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
    ratio_fps            = Constants.fps / Constants.replay_fps
    current_frame_weight = (ratio_fps - interpolation) / ratio_fps
    next_frame_weight    = interpolation               / ratio_fps

    frame = {}
    frame['mirror'] = current_frame.mirror
    for part in ['left_wheel', 'right_wheel', 'body', 'torso', 'upper_leg',
                 'lower_leg', 'upper_arm', 'lower_arm']
      frame[part] = weighted_position_2d(current_frame[part], next_frame[part],
                                         current_frame_weight, next_frame_weight)
    return frame

position_2d = (object) ->
  position:
    x:   object.GetPosition().x
    y:   object.GetPosition().y
  angle: object.GetAngle()

weighted_position_2d = (part_1, part_2, part_1_weight, part_2_weight) ->
  position:
    x:   part_1.position.x * part_1_weight + part_2.position.x * part_2_weight
    y:   part_1.position.y * part_1_weight + part_2.position.y * part_2_weight
  angle: part_1.angle      * part_1_weight + part_2.angle      * part_2_weight
