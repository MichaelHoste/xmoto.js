class Listeners

  constructor: (level) ->
    @level  = level
    @assets = level.assets
    @world  = level.physics.world

  init: ->
    # Add listeners for end of level
    listener = new Box2D.Dynamics.b2ContactListener

    listener.BeginContact = (contact) =>
      moto = @level.moto
      a = contact.GetFixtureA().GetBody().GetUserData()
      b = contact.GetFixtureB().GetBody().GetUserData()

      if not moto.dead
        # Strawberries
        if Listeners.does_contact_moto_rider(a, b, 'strawberry')
          strawberry = if a == 'strawberry' then contact.GetFixtureA() else contact.GetFixtureB()
          entity = strawberry.GetBody().GetUserData().entity
          if entity.display
            entity.display = false
            #createjs.Sound.play('PickUpStrawberry')

        # End of level
        else if Listeners.does_contact_moto_rider(a, b, 'end_of_level') and not @level.need_to_restart
          if @level.got_strawberries()
            @trigger_restart()

        # Fall of rider
        else if Listeners.does_contact(a, b, 'rider', 'ground') and a.part != 'lower_leg' and b.part != 'lower_leg'
          @kill_moto()

        # Wrecker contact
        else if Listeners.does_contact_moto_rider(a, b, 'wrecker')
          @kill_moto()

    @world.SetContactListener(listener)

  @does_contact_moto_rider: (a, b, obj) ->
    Listeners.does_contact(a, b, obj, 'rider') or Listeners.does_contact(a, b, obj, 'moto')

  @does_contact: (a, b, obj1, obj2) ->
    (a.name == obj1 and b.name == obj2) or (a.name == obj2 and b.name == obj1)

  trigger_restart: ->
    #createjs.Sound.play('EndOfLevel')
    @level.replay.success  = true
    @level.need_to_restart = true

  kill_moto: ->
    moto = @level.moto
    moto.dead = true

    #createjs.Sound.play('Headcrash')

    @world.DestroyJoint(moto.rider.ankle_joint)
    @world.DestroyJoint(moto.rider.wrist_joint)
    moto.rider.shoulder_joint.m_enableLimit = false

    moto.rider.knee_joint.m_lowerAngle     = moto.rider.knee_joint.m_lowerAngle  * 3
    moto.rider.elbow_joint.m_upperAngle    = moto.rider.elbow_joint.m_upperAngle * 3
    moto.rider.hip_joint.m_lowerAngle      = moto.rider.hip_joint.m_lowerAngle   * 3
