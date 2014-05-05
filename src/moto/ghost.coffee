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
      window.debug2 += "#{@level.physics.steps} - #{if current_input.up then 1 else 0} #{if current_input.down then 1 else 0} #{if current_input.left then 1 else 0} #{if current_input.right then 1 else 0} #{if current_input.space then 1 else 0}\n"

    @moto.move(current_input)

  display: (transparent = true) ->
    @moto.display()

