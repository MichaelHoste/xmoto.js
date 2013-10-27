class Listeners

  constructor: (level) ->
    @level  = level
    @assets = level.assets

  init: ->
    # Add listeners for end of level
    listener = new Box2D.Dynamics.b2ContactListener

    listener.BeginContact = (contact) =>
      moto = @level.moto
      a = contact.GetFixtureA().GetBody().GetUserData().name
      b = contact.GetFixtureB().GetBody().GetUserData().name

      if not moto.dead
        # Strawberries
        if (a == 'moto' and b == 'strawberry') || (a == 'rider' and b == 'strawberry') || (a == 'rider-lower_leg' and b == 'strawberry')
          strawberry = if a == 'strawberry' then contact.GetFixtureA() else contact.GetFixtureB()
          entity = strawberry.GetBody().GetUserData().entity
          if entity.display
            entity.display = false
            createjs.Sound.play('PickUpStrawberry')

        # End of level
        if (a == 'moto' and b == 'end_of_level') || (a == 'rider' and b == 'end_of_level')
          if @level.got_strawberries()
            createjs.Sound.play('EndOfLevel')
            @level.need_to_restart = true

        # Fall of rider
        else if a == 'rider' and b == 'ground'
          moto.dead = true

          createjs.Sound.play('Headcrash')

          @level.world.DestroyJoint(moto.rider.ankle_joint)
          @level.world.DestroyJoint(moto.rider.wrist_joint)

          moto.rider.knee_joint.m_lowerAngle     = moto.rider.knee_joint.m_lowerAngle     * 1.5
          moto.rider.elbow_joint.m_upperAngle    = moto.rider.elbow_joint.m_upperAngle    * 1.5
          moto.rider.shoulder_joint.m_upperAngle = moto.rider.shoulder_joint.m_upperAngle * 1.5
          moto.rider.hip_joint.m_lowerAngle      = moto.rider.hip_joint.m_lowerAngle      * 1.5

    @level.world.SetContactListener(listener)

