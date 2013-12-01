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
        if Listeners.does_contact_moto_rider(a, b, 'strawberry')
          strawberry = if a == 'strawberry' then contact.GetFixtureA() else contact.GetFixtureB()
          entity = strawberry.GetBody().GetUserData().entity
          if entity.display
            entity.display = false
            createjs.Sound.play('PickUpStrawberry')

        # End of level
        else if Listeners.does_contact_moto_rider(a, b, 'end_of_level')
          if @level.got_strawberries()
            createjs.Sound.play('EndOfLevel')
            @level.need_to_restart = true

        # Fall of rider
        else if Listeners.does_contact(a, b, 'rider', 'ground')
          @kill_moto()

        # Wrecker contact
        else if Listeners.does_contact_moto_rider(a, b, 'wrecker')
          @kill_moto()

    @level.world.SetContactListener(listener)

  @does_contact_moto_rider: (a, b, obj) ->
    Listeners.does_contact(a, b, obj, 'rider') or Listeners.does_contact(a, b, obj, 'moto')

  @does_contact: (a, b, obj1, obj2) ->
    (a == obj1 and b == obj2) or (a == obj2 and b == obj1)

  kill_moto: ->
    moto = @level.moto
    moto.dead = true

    createjs.Sound.play('Headcrash')

    @level.world.DestroyJoint(moto.rider.ankle_joint)
    @level.world.DestroyJoint(moto.rider.wrist_joint)

    moto.rider.knee_joint.m_lowerAngle     = moto.rider.knee_joint.m_lowerAngle     * 1.5
    moto.rider.elbow_joint.m_upperAngle    = moto.rider.elbow_joint.m_upperAngle    * 1.5
    moto.rider.shoulder_joint.m_upperAngle = moto.rider.shoulder_joint.m_upperAngle * 1.5
    moto.rider.hip_joint.m_lowerAngle      = moto.rider.hip_joint.m_lowerAngle      * 1.5
