# The only goal of this class is to flip the moto:
#
# Each parameter of each element of the moto is saved, then a flipped moto
# is created and the parameters are assigned so that the velocity the same

class MotoFlipService

  @run: (moto) ->
    # Accessible through "moto."
    moto_parts = [
      'body'
      'left_wheel'
      'right_wheel'
      'left_axle'
      'right_axle'
    ]

    # Accessible through "moto.rider."
    rider_parts = [
      'head'
      'torso'
      'lower_leg'
      'upper_leg'
      'lower_arm'
      'upper_arm'
    ]

    all_parts = moto_parts.concat(rider_parts)

    # values before mirroring: Like this:
    # {
    #   body:  { position:, angle:, linear:, angular: },
    #   torso: { position:, angle:, linear:, angular: },
    # }
    saved_values = {}

    for part in all_parts
      physics_part = if moto_parts.includes(part) then moto[part] else moto.rider[part]

      saved_values[part] =
        position: physics_part.getPosition()
        angle:    physics_part.getAngle()
        linear:   physics_part.getLinearVelocity()
        angular:  physics_part.getAngularVelocity()

    # Flag correct direction
    moto.mirror       = -moto.mirror
    moto.rider.mirror = -moto.rider.mirror

    # Recreate moto to have vertices in the correct direction
    moto.destroy()
    moto.init()

    # Reassign correct position + velocity values
    for part in all_parts
      physics_part = if moto_parts.includes(part) then moto[part] else moto.rider[part]
      saved        = saved_values[part]

      if part == 'left_wheel'
        physics_part.setPosition(saved_values['right_wheel'].position)
        physics_part.setAngle(-saved.angle)
        physics_part.setLinearVelocity(saved_values['right_wheel'].linear)
        physics_part.setAngularVelocity(-saved.angular)
      else if part == 'right_wheel'
        physics_part.setPosition(saved_values['left_wheel'].position)
        physics_part.setAngle(-saved.angle)
        physics_part.setLinearVelocity(saved_values['left_wheel'].linear)
        physics_part.setAngularVelocity(-saved.angular)
      else
        physics_part.setPosition(saved.position)
        physics_part.setAngle(saved.angle)
        physics_part.setLinearVelocity(saved.linear)
        physics_part.setAngularVelocity(saved.angular)
