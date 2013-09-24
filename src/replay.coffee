class Replay

  constructor: (level) ->
    @level  = level
    @replay = []

  add_frame: ->
    moto   = @level.moto
    rider  = @level.moto.rider

    frame =
      body:
        position: moto.body.GetPosition()
        angle:    moto.body.GetAngle()

    @replay.push(frame)

#    console.log(@replay.length)
