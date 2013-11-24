class ReplayFile

  constructor: ->
    @frames = []

  load_from_file: (file_name) ->
    $.ajax({
      type:     "GET",
      url:      "data/Replays/#{file_name}",
      dataType: "text",
      beforeSend: (xhr) -> xhr.overrideMimeType('text\/plain; charset=x-user-defined') # force binary
      success:  @load_replay
      async:    false
      context:  @
    })

  clone: (level) ->
    new_replay = new ReplayFile()
    new_replay.level = level
    for frame in @frames
      new_replay.frames.push($.extend(true, {}, frame))
    new_replay

  map8BitsToCoord: (ref, maxDiff, c) ->
    ref + c/127 * maxDiff

  map16BitsToAngle: (n16) ->
    n1 = parseInt(n16/256)
    n2 = n16%256
    pfM1 = (n1 - 127) / 127
    pfM2 = (n2 - 127) / 127
    if pfM2 > 0
      return Math.acos(pfM1)
    else
      return -Math.acos(pfM1)

  pointsToAngle: (x1, y1, x2, y2, extra90) ->
    extra90v = -Math.PI/2 * extra90

    if x1 > x2
      if y1 > y2
        return -Math.atan((x1-x2)/(y1-y2)) + extra90v # ok
      else
        return -Math.atan((x2-x1)/(y2-y1)) + Math.PI + extra90v # ok
    else
      if y1 > y2
        return -Math.atan((x1-x2)/(y1-y2)) + extra90v # ok
      else
        return -Math.atan((x2-x1)/(y2-y1)) + Math.PI + extra90v # ok

  load_replay: (bin) =>
    replay = new jDataView(bin, 0, bin.length, true)
    format = replay.getInt8()
    @load_replay_01(replay, format) if format == 0
    @load_replay_01(replay, format) if format == 1
    @load_replay_3(replay)          if format == 3

  load_replay_01: (replay, format) ->
    # header
    endian_check = replay.getInt32()
    n            = replay.getInt8()
    @levelId     = replay.getString(n)
    n            = replay.getInt8()
    @playerName  = replay.getString(n)
    frameRate    = replay.getFloat32()
    stateSize    = replay.getInt32()
    @finished    = replay.getInt8() == 1
    @finishTime  = replay.getFloat32()

    # events
    if format == 1 # format 1 includes events that format 0 doesn't
      dataSize   = replay.getInt32()
      compressed = replay.getInt8() == 1
      if compressed
        zdataSize = replay.getInt32()
        zdata     = replay.getBytes(zdataSize)
        data      = new Zlib.Inflate(zdata).decompress()
      else
        data = replay.getBytes(dataSize, 0, true, true)
      events = new jDataView(data, 0, data.length, true)
      #eventTime = events.getFloat32()
      #eventType = events.getInt32()

    # chunks
    nchunks      = replay.getInt32()
    for c in [0...nchunks]
      nstates    = replay.getInt32()
      compressed = replay.getInt8() == 1
      if compressed
        zdataSize = replay.getInt32()
        zdata     = replay.getBytes(zdataSize)
        data      = new Zlib.Inflate(zdata).decompress()
      else
        data = replay.getBytes(dataSize, 0, true, true)
      @load_chunks(data, nstates)

  load_chunks: (data, nstates) ->
    chunk = new jDataView(data, 0, data.length, true)
    for s in [0...nstates]
      flags    = chunk.getInt8()
      unused   = chunk.getBytes(3)
      gameTime = chunk.getFloat32()
      frameX   = chunk.getFloat32()
      frameY   = chunk.getFloat32()
      maxXDiff = chunk.getFloat32()
      maxYDiff = chunk.getFloat32()

      # angles
      fRearWheelRot  = @map16BitsToAngle(chunk.getUint16())
      fFrontWheelRot = @map16BitsToAngle(chunk.getUint16())
      fFrameRot      = @map16BitsToAngle(chunk.getUint16())

      # sound
      cBikeEngineRPM = chunk.getInt8()

      # wheels positions
      rearWheelPx  = @map8BitsToCoord(frameX, maxXDiff, chunk.getInt8())
      rearWheelPy  = @map8BitsToCoord(frameY, maxYDiff, chunk.getInt8())
      frontWheelPx = @map8BitsToCoord(frameX, maxXDiff, chunk.getInt8())
      frontWheelPy = @map8BitsToCoord(frameY, maxYDiff, chunk.getInt8())

      # bike
      centerPx = frameX; 
      centerPy = frameY;

      # body
      elbowX     = @map8BitsToCoord(frameX, maxXDiff, chunk.getInt8())
      elbowY     = @map8BitsToCoord(frameY, maxYDiff, chunk.getInt8())
      shoulderX  = @map8BitsToCoord(frameX, maxXDiff, chunk.getInt8())
      shoulderY  = @map8BitsToCoord(frameY, maxYDiff, chunk.getInt8())
      lowerBodyX = @map8BitsToCoord(frameX, maxXDiff, chunk.getInt8())
      lowerBodyY = @map8BitsToCoord(frameY, maxYDiff, chunk.getInt8())
      kneeX      = @map8BitsToCoord(frameX, maxXDiff, chunk.getInt8())
      kneeY      = @map8BitsToCoord(frameY, maxYDiff, chunk.getInt8())
      unused     = chunk.getBytes(1)

      if flags == 1
        sensmult = -1
      else
        sensmult = 1

      frame =
        mirror: flags == 1
        left_wheel:
          position:
            x: rearWheelPx
            y: rearWheelPy
          angle: fRearWheelRot
        right_wheel:
          position:
            x: frontWheelPx
            y: frontWheelPy
          angle: fFrontWheelRot
        body:
          position:
            x: centerPx
            y: centerPy
          angle: fFrameRot
        torso:
          position:
            x: (shoulderX-Constants.shoulder.axe_position.x + lowerBodyX-Constants.hip.axe_position.x)/2
            y: (shoulderY-Constants.shoulder.axe_position.y + lowerBodyY-Constants.hip.axe_position.y)/2
          angle: @pointsToAngle(shoulderX, shoulderY, lowerBodyX, lowerBodyY, 0)

        upper_leg:
          position:
            x: (lowerBodyX-Constants.hip.axe_position.x + kneeX-Constants.knee.axe_position.x)/2
            y: (lowerBodyY-Constants.hip.axe_position.y + kneeY-Constants.knee.axe_position.y)/2
          angle: @pointsToAngle(lowerBodyX, lowerBodyY, kneeX, kneeY, 1)

        lower_leg:
          position:
            x: (kneeX+Constants.ankle.axe_position.x+centerPx)/2
            y: (kneeY+Constants.ankle.axe_position.y+centerPy)/2
          angle: @pointsToAngle(kneeX, kneeY, centerPx, centerPy, 0)

        upper_arm:
          position:
            x: (shoulderX+elbowX)/2
            y: (shoulderY+elbowY)/2
          angle: @pointsToAngle(shoulderX, shoulderY, elbowX, elbowY, 0)

        lower_arm:
          position:
            x: (elbowX+centerPx)/2
            y: (elbowY+centerPy)/2
          angle: @pointsToAngle(elbowX, elbowY, centerPx, centerPy, 0)

        anchors:
          elbow:
            x: elbowX
            y: elbowY
          shoulder:
            x: shoulderX
            y: shoulderY
          hip:
            x: lowerBodyX
            y: lowerBodyY
          knee:
            x: kneeX
            y: kneeY
          wrist:
            x: centerPx+sensmult*Constants.cpp.rider_hand.x*Math.cos(fFrameRot)-Constants.cpp.rider_hand.y*Math.sin(fFrameRot)
            y: centerPy+sensmult*Constants.cpp.rider_hand.x*Math.sin(fFrameRot)+Constants.cpp.rider_hand.y*Math.cos(fFrameRot)
          ankle:
            x: centerPx+sensmult*Constants.cpp.rider_foot.x*Math.cos(fFrameRot)-Constants.cpp.rider_foot.y*Math.sin(fFrameRot)
            y: centerPy+sensmult*Constants.cpp.rider_foot.x*Math.sin(fFrameRot)+Constants.cpp.rider_foot.y*Math.cos(fFrameRot)
          neck:
            x: shoulderX + Constants.cpp.rider_neck_length*@normalizeX(shoulderX-lowerBodyX, shoulderY-lowerBodyY)
            y: shoulderY + Constants.cpp.rider_neck_length*@normalizeY(shoulderX-lowerBodyX, shoulderY-lowerBodyY)

      for i in [0..1]
        @frames.push(frame)

  length: (x, y) ->
    Math.sqrt(x*x + y*y)

  normalizeX: (x, y) ->
    v = @length(x, y)
    return 0 if v == 0
    return x/v

  normalizeY: (x, y) ->
    v = @length(x, y)
    return 0 if v == 0
    return y/v

  load_replay_2: (replay) ->
    todo = true

  load_replay_3: (replay) ->
    todo = true

  frames_count: ->
    @frames.length

  frame: (number) ->
    @frames[number]

  position_2d = (object) ->
    position:
      x: object.GetPosition().x
      y: object.GetPosition().y
    angle: object.GetAngle()
