class Ghosts

  constructor: (level) ->
    @level   = level
    @assets  = level.assets

    # Create replay and load the user's best score (from an id in the DOM)
    replay   = new Replay(@level).load()
    @player  = new Ghost(@level, replay)

    @others  = []

  display: ->
    @player.display()
    for ghost in @others
      ghost.display()

  init: ->
    # Assets
    parts = [ Constants.torso, Constants.upper_leg, Constants.lower_leg,
              Constants.upper_arm, Constants.lower_arm,
              Constants.body, Constants.left_wheel, Constants.right_wheel,
              Constants.left_axle, Constants.right_axle ]
    for part in parts
      @assets.moto.push(part.ghost_texture)
