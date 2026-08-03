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
    # List of events here: https://piqnt.com/planck.js/docs/api/classes/World.html#on
    # https://piqnt.com/planck.js/docs/contacts.html#contact-events
    @world.on('begin-contact', (contact) =>
      moto = @active_moto()

      a = contact.getFixtureA().getBody().getUserData()
      b = contact.getFixtureB().getBody().getUserData()

      if !moto.dead
        # Strawberries
        if Listeners.does_contact_moto_rider(a, b, 'strawberry')
          strawberry = if a.name == 'strawberry' then contact.getFixtureA() else contact.getFixtureB()

          entity = strawberry.getBody().getUserData().entity
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
    )

  @does_contact_moto_rider: (a, b, obj) ->
    collision = Listeners.does_contact(a, b, obj, 'rider') || Listeners.does_contact(a, b, obj, 'moto')
    player    = a.type == 'player' || b.type == 'player'

    return (collision && player)

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

      shoulder_joint = moto.rider.shoulder_joint
      knee_joint     = moto.rider.knee_joint
      elbow_joint    = moto.rider.elbow_joint
      hip_joint      = moto.rider.hip_joint

      shoulder_joint.enableLimit(false)

      knee_joint.setLimits(
        knee_joint.getLowerLimit() * 3,
        knee_joint.getUpperLimit()
      )

      elbow_joint.setLimits(
        elbow_joint.getLowerLimit(),
        elbow_joint.getUpperLimit() * 3
      )

      hip_joint.setLimits(
        hip_joint.getLowerLimit() * 3,
        hip_joint.getUpperLimit()
      )

      # kill_moto is called from the 'begin-contact' listener while the world
      # is mid-step (locked), where world.destroyJoint() silently no-ops (see
      # planck's World#isLocked guard)
      @world.queueUpdate =>
        @world.destroyJoint(moto.rider.ankle_joint)
        @world.destroyJoint(moto.rider.wrist_joint)

