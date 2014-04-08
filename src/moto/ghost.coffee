class Ghost

  constructor: (level, replay) ->
    @level   = level
    @replay  = replay
    @moto    = new Moto(@level, true)

  init: ->
    @moto.init()

  reload: ->
    @moto.destroy()
    @moto = new Moto(@level, true)
    @moto.init()

  move: ->
    current_input =
      up:    @replay.is_down('up')
      down:  @replay.is_down('down')
      left:  @replay.is_down('left')
      right: @replay.is_down('right')
      space: @replay.is_pressed('space')

    if !@level.moto.dead
      ;
      #console.log("#{@level.physics.steps} - #{current_input.up} #{current_input.down} #{current_input.left} #{current_input.right} #{current_input.space}")

    @moto.move(current_input)

  display: (transparent = true) ->
    @moto.display()

