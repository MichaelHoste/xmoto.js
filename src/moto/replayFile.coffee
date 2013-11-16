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
    n2 = n16-n1
    n2 = parseInt(n2/256)

    pfM1 = (n1 - 127) / 127
    pfM2 = (n2 - 127) / 127

    if pfM1 > 0
      if pfM2 > 0
        return Math.acos(pfM1)
      else
        return Math.acos(pfM1) - Math.PI/2
    else
      if pfM2 > 0
        return Math.acos(pfM1) + Math.PI
      else
        return Math.acos(pfM1) + Math.PI/2

  load_replay: (bin) =>
    replay = new jDataView(bin, 0, bin.length, true)
    format = replay.getInt8()
    @load_replay_01(replay, format) if format == 0
    @load_replay_01(replay, format) if format == 1
    @load_replay_2(replay)          if format == 2
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

      nRearWheelRot  = chunk.getUint16()
      nFrontWheelRot = chunk.getUint16()
      nFrameRot      = chunk.getUint16()

      # angles
      fRearWheelRot  = @map16BitsToAngle(nRearWheelRot)
      fFrontWheelRot = @map16BitsToAngle(nFrontWheelRot)
      fFrameRot      = @map16BitsToAngle(nFrameRot)

      cBikeEngineRPM = chunk.getInt8()

      # wheels
      cRearWheelX    = chunk.getInt8()
      cRearWheelY    = chunk.getInt8()
      cFrontWheelX   = chunk.getInt8()
      cFrontWheelY   = chunk.getInt8()
      rearWheelPx  = @map8BitsToCoord(frameX, maxXDiff, cRearWheelX) 
      rearWheelPy  = @map8BitsToCoord(frameY, maxYDiff, cRearWheelY)
      frontWheelPx = @map8BitsToCoord(frameX, maxXDiff, cFrontWheelX) 
      frontWheelPy = @map8BitsToCoord(frameY, maxYDiff, cFrontWheelY)

      centerPx = frameX; 
      centerPy = frameY;

      cElbowX        = chunk.getInt8()
      cElbowY        = chunk.getInt8()
      cShoulderX     = chunk.getInt8()
      cShoulderY     = chunk.getInt8()
      cLowerBodyX    = chunk.getInt8()
      cLowerBodyY    = chunk.getInt8()
      cKneeX         = chunk.getInt8()
      cKneeY         = chunk.getInt8()
      unused         = chunk.getBytes(1)

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
            x: (cShoulderX+cLowerBodyX)/2
            y: (cShoulderY+cLowerBodyY)/2
          angle: fFrameRot

        upper_leg:
          position:
            x: (cLowerBodyX+cKneeX)/2
            y: (cLowerBodyY+cKneeY)/2
          angle: fFrameRot

        lower_leg:
          position:
            x: (cKneeX+centerPx)/2
            y: (cKneeY+centerPy)/2
          angle: fFrameRot

        upper_arm:
          position:
            x: (cShoulderX+cElbowX)/2
            y: (cShoulderY+cElbowY)/2
          angle: fFrameRot

        lower_arm:
          position:
            x: 0
            y: 0
          angle: fFrameRot

      for i in [0..4]
        @frames.push(frame)

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
