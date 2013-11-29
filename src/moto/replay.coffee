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
      anchors:
        elbow:    @level.moto.rider.elbow_joint.GetAnchorA()
        shoulder: @level.moto.rider.shoulder_joint.GetAnchorA()
        hip:      @level.moto.rider.hip_joint.GetAnchorA()
        knee:     @level.moto.rider.knee_joint.GetAnchorA()
        wrist:    @level.moto.rider.wrist_joint.GetAnchorA()
        ankle:    @level.moto.rider.ankle_joint.GetAnchorA()
        neck:     @level.moto.rider.neck_joint.GetAnchorA()

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
