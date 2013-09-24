class Replay

  constructor: (level) ->
    @level         = level
    @frames        = []

  add_frame: ->
    moto   = @level.moto
    rider  = @level.moto.rider

    frame =
      body:
        position: moto.body.GetPosition()
        angle:    moto.body.GetAngle()

    @frames.push(frame)

  frame: (number) ->
    @frames[number]
