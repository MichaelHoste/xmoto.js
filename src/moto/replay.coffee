class Replay

  constructor: (level) ->
    @level  = level
    @frames = []

  clone: ->
    new_replay = new Replay(@level)
    for frame in @frames
      new_replay.frames.push($.extend(true, {}, frame))
    new_replay

  add_frame: ->
    moto   = @level.moto
    rider  = @level.moto.rider

    frame =
      mirror    :  @level.moto.mirror == -1 # true if moto is reversed
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
    @frames[number]

position_2d = (object) ->
  position:
    x: object.GetPosition().x
    y: object.GetPosition().y
  angle: object.GetAngle()
