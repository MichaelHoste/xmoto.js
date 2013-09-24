class Replay

  constructor: (level) ->
    @level  = level
    @moto   = level.moto
    @rider  = level.moto.rider
    @replay = []

  add_frame: ->
    frame =
      body:
        position: @moto.body.GetPosition()
        angle:    @moto.body.GetAngle()

    @replay.push(frame)
