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

  DEBUG = true # if true, will freeze when flipping to check positions

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

    # To get the new offset: undo the body's rotation to read the offset
    # in its local frame, mirror the local x, then re-apply the SAME
    # (unchanged) rotation:
    #
    #   local  = un-rotate (offset from body) by the body's angle
    #   local' = mirror local.x
    #   offset'= re-rotate local' by that same body angle
    #
    # This is equivalent to reflecting across the wheelbase line itself
    # (whatever direction it currently points), rather than across a fixed
    # vertical axis - which is exactly "swap front and back along the slope
    # you're currently on". It keeps every part's offset consistent with its
    # own joints at any angle (unlike literally swapping left_wheel/right_wheel:
    # their axles are NOT mirror-image shapes - see Constants - so relocating
    # one to the other's spot leaves its joints anchored to geometry that no
    # longer lines up, and the solver fights it every subsequent step).
    saved_body    = saved_values['body']
    body_pos      = saved_body.position
    old_angle     = saved_body.angle
    old_angular   = saved_body.angular

    # body/wheels/axles/head are always built at a fixed angle of 0 (mirror
    # only affects their position/vertices - see Moto#create_body,
    # Moto#create_wheel, Rider#create_head), so their own angle doesn't need
    # to change at all.
    #
    # torso/legs/arms are different: Rider#create_part builds them with
    # `angle = mirror * part_constants.angle`, i.e. their rest angle is
    # itself mirror-dependent (their revolute joints even have mirror-flipped
    # limits - see Rider#create_joint). Keeping their absolute angle
    # unchanged desyncs them from the body they're mirrored around and tears
    # the ragdoll apart (confirmed visually: torso/limbs stretch away from
    # the seat right after the flip). They must mirror relative to the body's
    # angle instead: new_angle = 2*body_angle - old_angle (and the same
    # relation for angular velocity, so they keep moving consistently with
    # the now-mirrored body).
    for part in all_parts
      physics_part = if moto_parts.includes(part) then moto[part] else moto.rider[part]
      saved        = saved_values[part]

      world_offset = { x: saved.position.x - body_pos.x, y: saved.position.y - body_pos.y }
      local_offset = Math2D.rotate_point(world_offset, -old_angle, { x: 0, y: 0 })
      local_offset.x = -local_offset.x
      new_offset   = Math2D.rotate_point(local_offset, old_angle, { x: 0, y: 0 })
      new_position = { x: body_pos.x + new_offset.x, y: body_pos.y + new_offset.y }

      new_angle = 2*old_angle - saved.angle

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
