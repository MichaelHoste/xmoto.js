class Listeners

  constructor: (level) ->
    @level  = level
    @assets = level.assets
    @world  = level.physics.world

  active_moto: ->
    if @level.options.playable
      @level.moto
    else
      @level.ghosts.player.moto

  init: ->
    # Add listeners for end of level
    listener = new Box2D.Dynamics.b2ContactListener

    listener.BeginContact = (contact) =>
      moto = @active_moto()

      a = contact.GetFixtureA().GetBody().GetUserData()
      b = contact.GetFixtureB().GetBody().GetUserData()

      if !moto.dead
        # Strawberries
        if Listeners.does_contact_moto_rider(a, b, 'strawberry')
          strawberry   = if a.name == 'strawberry' then contact.GetFixtureA() else contact.GetFixtureB()

          entity = strawberry.GetBody().GetUserData().entity
          if entity.display
            entity.display = false
            #createjs.Sound.play('PickUpStrawberry')

        # End of level
        else if Listeners.does_contact_moto_rider(a, b, 'end_of_level') and not @level.need_to_restart
          if @level.got_strawberries()
            if a.name == 'rider' || b.name == 'rider'
              moto = if a.name == 'rider' then a.rider.moto else b.rider.moto
            else
              moto = if a.name == 'moto' then a.moto else b.moto

            @trigger_restart(moto)

        # Fall of rider
        else if Constants.hooking == false and
                Listeners.does_contact(a, b, 'rider', 'ground') and
                a.part != 'lower_leg' and b.part != 'lower_leg'
          moto = if a.name == 'rider' then a.rider.moto else b.rider.moto
          @kill_moto(moto)

        else if Constants.hooking == true and
                Listeners.does_contact(a, b, 'rider', 'ground') and
                (a.part == 'head' or b.part == 'head')
          moto = if a.name == 'rider' then a.rider.moto else b.rider.moto
          @kill_moto(moto)

        # Wrecker contact
        else if Listeners.does_contact_moto_rider(a, b, 'wrecker')
          if a.name == 'rider' || b.name == 'rider'
            moto = if a.name == 'rider' then a.rider.moto else b.rider.moto
          else
            moto = if a.name == 'moto' then a.moto else b.moto
          @kill_moto(moto)

    @world.SetContactListener(listener)

  @does_contact_moto_rider: (a, b, obj) ->
    Listeners.does_contact(a, b, obj, 'rider') || Listeners.does_contact(a, b, obj, 'moto')

  @does_contact: (a, b, obj1, obj2) ->
    (a.name == obj1 && b.name == obj2) || (a.name == obj2 && b.name == obj1)

  trigger_restart: (moto) ->
    #createjs.Sound.play('EndOfLevel')
    if moto.ghost
      moto.dead = true
    else
      @level.replay.success  = true
      @level.need_to_restart = true

  kill_moto: (moto) ->
    if !moto.dead
      moto.dead = true

      # Cause the game to "hard" crash because reactivation of collisions when in the middle of it
      #@level.moto.rider.torso.GetFixtureList().SetSensor(false)
      #@level.moto.rider.lower_leg.GetFixtureList().SetSensor(false)
      #@level.moto.rider.upper_leg.GetFixtureList().SetSensor(false)
      #@level.moto.rider.lower_arm.GetFixtureList().SetSensor(false)
      #@level.moto.rider.upper_arm.GetFixtureList().SetSensor(false)
      #@level.moto.body.GetFixtureList().SetSensor(false)
      #@level.moto.left_axle.GetFixtureList().SetSensor(false)
      #@level.moto.right_axle.GetFixtureList().SetSensor(false)

      #createjs.Sound.play('Headcrash')

      @world.DestroyJoint(moto.rider.ankle_joint)
      @world.DestroyJoint(moto.rider.wrist_joint)
      moto.rider.shoulder_joint.m_enableLimit = false

      moto.rider.knee_joint.m_lowerAngle  = moto.rider.knee_joint.m_lowerAngle  * 3
      moto.rider.elbow_joint.m_upperAngle = moto.rider.elbow_joint.m_upperAngle * 3
      moto.rider.hip_joint.m_lowerAngle   = moto.rider.hip_joint.m_lowerAngle   * 3

