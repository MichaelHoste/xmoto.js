# The only goal of this class is to flip the moto:
#
# Each parameter of each element of the moto is saved, then a flipped moto
# is created and the parameters are assigned to ensure continuity

# RESULTS:
# --------
# Contrary to the legacy method of MotoFlipLegacyService, the positions of all flipped
# physics objects are correct, for every moto angle, even while looping.
# But:
#  * Velocity (linear/angular) and maybe joints values create issues when looping against a wall (level 1)
#  * This method is not generic yet (it needs to manage wheels differently), so it may still be improved!
# ---
# Use DEBUG=true and flip the moto to observe
# ---

class MotoFlipService

  DEBUG = false # if true, will freeze when flipping to check positions

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
    # --
    # To get the new offset: undo the body's rotation to read the offset
    # in its local frame, mirror the local x, then re-apply the SAME
    # (unchanged) rotation:
    #
    #   local  = un-rotate (offset from body) by the body's angle
    #   local' = mirror local.x
    #   offset'= re-rotate local' by that same body angle
    #
    body_position = saved_values['body'].position
    body_angle    = saved_values['body'].angle

    for part in all_parts
      physics_part = if moto_parts.includes(part) then moto[part] else moto.rider[part]
      saved        = saved_values[part]

      world_offset = { x: saved.position.x - body_position.x, y: saved.position.y - body_position.y }
      local_offset = Math2D.rotate_point(world_offset, -body_angle, { x: 0, y: 0 })
      local_offset.x = -local_offset.x
      new_offset   = Math2D.rotate_point(local_offset, body_angle, { x: 0, y: 0 })
      new_position = { x: body_position.x + new_offset.x, y: body_position.y + new_offset.y }

      new_angle = 2*body_angle - saved.angle

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
        physics_part.setPosition(new_position)
        physics_part.setAngle(new_angle)
        physics_part.setLinearVelocity(saved.linear)
        physics_part.setAngularVelocity(saved.angular)

      if DEBUG
        physics_part.setType('static')
