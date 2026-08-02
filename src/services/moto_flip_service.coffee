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
      position: moto.body.getPosition()
      angle:    moto.body.getAngle()
      linear:   moto.body.getLinearVelocity()
      angular:  moto.body.getAngularVelocity()

    left_wheel =
      position: moto.left_wheel.getPosition()
      angle:    moto.left_wheel.getAngle()
      linear:   moto.left_wheel.getLinearVelocity()
      angular:  moto.left_wheel.getAngularVelocity()

    right_wheel =
      position: moto.right_wheel.getPosition()
      angle:    moto.right_wheel.getAngle()
      linear:   moto.right_wheel.getLinearVelocity()
      angular:  moto.right_wheel.getAngularVelocity()

    left_axle =
      position: moto.left_axle.getPosition()
      angle:    moto.left_axle.getAngle()
      linear:   moto.left_axle.getLinearVelocity()
      angular:  moto.left_axle.getAngularVelocity()

    right_axle =
      position: moto.right_axle.getPosition()
      angle:    moto.right_axle.getAngle()
      linear:   moto.right_axle.getLinearVelocity()
      angular:  moto.right_axle.getAngularVelocity()

    head =
      position: moto.rider.head.getPosition()
      angle:    moto.rider.head.getAngle()
      linear:   moto.rider.head.getLinearVelocity()
      angular:  moto.rider.head.getAngularVelocity()

    torso =
      position: moto.rider.torso.getPosition()
      angle:    moto.rider.torso.getAngle()
      linear:   moto.rider.torso.getLinearVelocity()
      angular:  moto.rider.torso.getAngularVelocity()

    lower_leg =
      position: moto.rider.lower_leg.getPosition()
      angle:    moto.rider.lower_leg.getAngle()
      linear:   moto.rider.lower_leg.getLinearVelocity()
      angular:  moto.rider.lower_leg.getAngularVelocity()

    upper_leg =
      position: moto.rider.upper_leg.getPosition()
      angle:    moto.rider.upper_leg.getAngle()
      linear:   moto.rider.upper_leg.getLinearVelocity()
      angular:  moto.rider.upper_leg.getAngularVelocity()

    lower_arm =
      position: moto.rider.lower_arm.getPosition()
      angle:    moto.rider.lower_arm.getAngle()
      linear:   moto.rider.lower_arm.getLinearVelocity()
      angular:  moto.rider.lower_arm.getAngularVelocity()

    upper_arm =
      position: moto.rider.upper_arm.getPosition()
      angle:    moto.rider.upper_arm.getAngle()
      linear:   moto.rider.upper_arm.getLinearVelocity()
      angular:  moto.rider.upper_arm.getAngularVelocity()

    moto.mirror = moto.rider.mirror = -moto.mirror
    moto.destroy()
    moto.init()

    moto.body           .setPosition(body.position)
    moto.body           .setAngle(body.angle)
    moto.body           .setLinearVelocity(body.linear)
    moto.body           .setAngularVelocity(body.angular)

    # !!! Position and speed of right_wheel and angular velocity of left_wheel it's normal !
    moto.left_wheel     .setPosition(right_wheel.position)
    moto.left_wheel     .setAngle(-left_wheel.angle)
    moto.left_wheel     .setLinearVelocity(right_wheel.linear)
    moto.left_wheel     .setAngularVelocity(-left_wheel.angular)

    # !!! Position and speed of left_wheel and angular velocity of right_wheel it's normal !
    moto.right_wheel    .setPosition(left_wheel.position)
    moto.right_wheel    .setAngle(-right_wheel.angle)
    moto.right_wheel    .setLinearVelocity(left_wheel.linear)
    moto.right_wheel    .setAngularVelocity(-right_wheel.angular)

    moto.left_axle      .setPosition(left_axle.position)
    moto.left_axle      .setAngle(left_axle.angle)
    moto.left_axle      .setLinearVelocity(left_axle.linear)
    moto.left_axle      .setAngularVelocity(left_axle.angular)

    moto.right_axle     .setPosition(right_axle.position)
    moto.right_axle     .setAngle(right_axle.angle)
    moto.right_axle     .setLinearVelocity(right_axle.linear)
    moto.right_axle     .setAngularVelocity(right_axle.angular)

    moto.rider.head     .setPosition(head.position)
    moto.rider.head     .setAngle(head.angle)
    moto.rider.head     .setLinearVelocity(head.linear)
    moto.rider.head     .setAngularVelocity(head.angular)

    moto.rider.torso    .setPosition(torso.position)
    moto.rider.torso    .setAngle(torso.angle)
    moto.rider.torso    .setLinearVelocity(torso.linear)
    moto.rider.torso    .setAngularVelocity(torso.angular)

    moto.rider.lower_leg.setPosition(lower_leg.position)
    moto.rider.lower_leg.setAngle(lower_leg.angle)
    moto.rider.lower_leg.setLinearVelocity(lower_leg.linear)
    moto.rider.lower_leg.setAngularVelocity(lower_leg.angular)

    moto.rider.upper_leg.setPosition(upper_leg.position)
    moto.rider.upper_leg.setAngle(upper_leg.angle)
    moto.rider.upper_leg.setLinearVelocity(upper_leg.linear)
    moto.rider.upper_leg.setAngularVelocity(upper_leg.angular)

    moto.rider.lower_arm.setPosition(lower_arm.position)
    moto.rider.lower_arm.setAngle(lower_arm.angle)
    moto.rider.lower_arm.setLinearVelocity(lower_arm.linear)
    moto.rider.lower_arm.setAngularVelocity(lower_arm.angular)

    moto.rider.upper_arm.setPosition(upper_arm.position)
    moto.rider.upper_arm.setAngle(upper_arm.angle)
    moto.rider.upper_arm.setLinearVelocity(upper_arm.linear)
    moto.rider.upper_arm.setAngularVelocity(upper_arm.angular)
