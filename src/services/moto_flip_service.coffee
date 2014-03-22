# The only goal of this class is to flip the moto :
#
# Each parameter of each element of the moto is saved, then a flipped moto
# is created and the parameters are assigned so that the velocity the same
#
# Careful, the position of the left wheel is assigned to the one of the
# right wheel and vice-versa (this is symmetric, it's normal!)

class MotoFlipService

  @execute: (moto) ->
    body =
      position: moto.body.GetPosition()
      angle:    moto.body.GetAngle()
      linear:   moto.body.GetLinearVelocity()
      angular:  moto.body.GetAngularVelocity()

    left_wheel =
      position: moto.left_wheel.GetPosition()
      angle:    moto.left_wheel.GetAngle()
      linear:   moto.left_wheel.GetLinearVelocity()
      angular:  moto.left_wheel.GetAngularVelocity()

    right_wheel =
      position: moto.right_wheel.GetPosition()
      angle:    moto.right_wheel.GetAngle()
      linear:   moto.right_wheel.GetLinearVelocity()
      angular:  moto.right_wheel.GetAngularVelocity()

    left_axle =
      position: moto.left_axle.GetPosition()
      angle:    moto.left_axle.GetAngle()
      linear:   moto.left_axle.GetLinearVelocity()
      angular:  moto.left_axle.GetAngularVelocity()

    right_axle =
      position: moto.right_axle.GetPosition()
      angle:    moto.right_axle.GetAngle()
      linear:   moto.right_axle.GetLinearVelocity()
      angular:  moto.right_axle.GetAngularVelocity()

    head =
      position: moto.rider.head.GetPosition()
      angle:    moto.rider.head.GetAngle()
      linear:   moto.rider.head.GetLinearVelocity()
      angular:  moto.rider.head.GetAngularVelocity()

    torso =
      position: moto.rider.torso.GetPosition()
      angle:    moto.rider.torso.GetAngle()
      linear:   moto.rider.torso.GetLinearVelocity()
      angular:  moto.rider.torso.GetAngularVelocity()

    lower_leg =
      position: moto.rider.lower_leg.GetPosition()
      angle:    moto.rider.lower_leg.GetAngle()
      linear:   moto.rider.lower_leg.GetLinearVelocity()
      angular:  moto.rider.lower_leg.GetAngularVelocity()

    upper_leg =
      position: moto.rider.upper_leg.GetPosition()
      angle:    moto.rider.upper_leg.GetAngle()
      linear:   moto.rider.upper_leg.GetLinearVelocity()
      angular:  moto.rider.upper_leg.GetAngularVelocity()

    lower_arm =
      position: moto.rider.lower_arm.GetPosition()
      angle:    moto.rider.lower_arm.GetAngle()
      linear:   moto.rider.lower_arm.GetLinearVelocity()
      angular:  moto.rider.lower_arm.GetAngularVelocity()

    upper_arm =
      position: moto.rider.upper_arm.GetPosition()
      angle:    moto.rider.upper_arm.GetAngle()
      linear:   moto.rider.upper_arm.GetLinearVelocity()
      angular:  moto.rider.upper_arm.GetAngularVelocity()

    mirror = moto.mirror == 1
    level  = moto.level

    moto.destroy()
    moto = new Moto(level, mirror)
    moto.init()

    moto.body           .SetPosition(body.position)
    moto.body           .SetAngle(body.angle)
    moto.body           .SetLinearVelocity(body.linear)
    moto.body           .SetAngularVelocity(body.angular)

    # !!! Position and speed of right_wheel and angular velocity of left_wheel it's normal !
    moto.left_wheel     .SetPosition(right_wheel.position)
    moto.left_wheel     .SetAngle(-left_wheel.angle)
    moto.left_wheel     .SetLinearVelocity(right_wheel.linear)
    moto.left_wheel     .SetAngularVelocity(-left_wheel.angular)

    # !!! Position and speed of left_wheel and angular velocity of right_wheel it's normal !
    moto.right_wheel    .SetPosition(left_wheel.position)
    moto.right_wheel    .SetAngle(-right_wheel.angle)
    moto.right_wheel    .SetLinearVelocity(left_wheel.linear)
    moto.right_wheel    .SetAngularVelocity(-right_wheel.angular)

    moto.left_axle      .SetPosition(left_axle.position)
    moto.left_axle      .SetAngle(left_axle.angle)
    moto.left_axle      .SetLinearVelocity(left_axle.linear)
    moto.left_axle      .SetAngularVelocity(left_axle.angular)

    moto.right_axle     .SetPosition(right_axle.position)
    moto.right_axle     .SetAngle(right_axle.angle)
    moto.right_axle     .SetLinearVelocity(right_axle.linear)
    moto.right_axle     .SetAngularVelocity(right_axle.angular)

    moto.rider.head     .SetPosition(head.position)
    moto.rider.head     .SetAngle(head.angle)
    moto.rider.head     .SetLinearVelocity(head.linear)
    moto.rider.head     .SetAngularVelocity(head.angular)

    moto.rider.torso    .SetPosition(torso.position)
    moto.rider.torso    .SetAngle(torso.angle)
    moto.rider.torso    .SetLinearVelocity(torso.linear)
    moto.rider.torso    .SetAngularVelocity(torso.angular)

    moto.rider.lower_leg.SetPosition(lower_leg.position)
    moto.rider.lower_leg.SetAngle(lower_leg.angle)
    moto.rider.lower_leg.SetLinearVelocity(lower_leg.linear)
    moto.rider.lower_leg.SetAngularVelocity(lower_leg.angular)

    moto.rider.upper_leg.SetPosition(upper_leg.position)
    moto.rider.upper_leg.SetAngle(upper_leg.angle)
    moto.rider.upper_leg.SetLinearVelocity(upper_leg.linear)
    moto.rider.upper_leg.SetAngularVelocity(upper_leg.angular)

    moto.rider.lower_arm.SetPosition(lower_arm.position)
    moto.rider.lower_arm.SetAngle(lower_arm.angle)
    moto.rider.lower_arm.SetLinearVelocity(lower_arm.linear)
    moto.rider.lower_arm.SetAngularVelocity(lower_arm.angular)

    moto.rider.upper_arm.SetPosition(upper_arm.position)
    moto.rider.upper_arm.SetAngle(upper_arm.angle)
    moto.rider.upper_arm.SetLinearVelocity(upper_arm.linear)
    moto.rider.upper_arm.SetAngularVelocity(upper_arm.angular)

    moto
