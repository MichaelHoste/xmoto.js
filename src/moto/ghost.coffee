class Ghost

  constructor: (level, replay, transparent = true) ->
    @level        = level
    @replay       = replay
    @transparent  = transparent
    @moto         = new Moto(@level, @transparent)

  init: ->
    @moto.init()

  reload: ->
    @moto.destroy()
    @moto = new Moto(@level, @transparent)
    @moto.init()

  move: ->
    @move_with_input()    # every steps
    @move_with_key_step() # only when key step

  move_with_input: ->
    current_input =
      up:    @replay.is_down('up')
      down:  @replay.is_down('down')
      left:  @replay.is_down('left')
      right: @replay.is_down('right')
      space: @replay.is_pressed('space')

    @moto.move(current_input)

  move_with_key_step: ->
    key_step = @replay.key_steps[@level.physics.steps]
    if key_step
      for part in ['body', 'left_wheel', 'right_wheel', 'left_axle', 'right_axle']
        @set_part_position(@moto, part, key_step)

      for part in ['torso', 'upper_leg', 'lower_leg', 'upper_arm', 'lower_arm']
        @set_part_position(@moto.rider, part, key_step)

  update: ->
    @moto.update()

  set_part_position: (entity, part, key_step) ->
    entity[part].SetPosition(
      x: key_step[part].position.x
      y: key_step[part].position.y
    )
    entity[part].SetAngle(key_step[part].angle)
    entity[part].SetLinearVelocity(
      x: key_step[part].linear_velocity.x
      y: key_step[part].linear_velocity.y
    )
    entity[part].GetAngularVelocity(key_step[part].angular_velocity)
