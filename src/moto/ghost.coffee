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

    @moto.move(current_input)

    milestone = @replay.milestones[@level.physics.steps]
    if milestone
      for part in ['body', 'left_wheel', 'right_wheel', 'left_axle', 'right_axle']
        @moto[part].SetPosition(
          x: milestone[part].position.x
          y: milestone[part].position.y
        )
        @moto[part].SetAngle(milestone[part].angle)
        @moto[part].SetLinearVelocity(
          x: milestone[part].linear_velocity.x
          y: milestone[part].linear_velocity.y
        )
        @moto[part].GetAngularVelocity(milestone[part].angular_velocity)

      for part in ['torso', 'upper_leg', 'lower_leg', 'upper_arm', 'lower_arm']
        @moto.rider[part].SetPosition(
          x: milestone[part].position.x
          y: milestone[part].position.y
        )
        @moto.rider[part].SetAngle(milestone[part].angle)
        @moto.rider[part].SetLinearVelocity(
          x: milestone[part].linear_velocity.x
          y: milestone[part].linear_velocity.y
        )
        @moto.rider[part].GetAngularVelocity(milestone[part].angular_velocity)

  display: (transparent = true) ->
    @moto.display()

