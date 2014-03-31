class Ghosts

  constructor: (level) ->
    @level   = level
    @assets  = level.assets

    @replay = @load_replay() # Create replay in "replay only" mode (from options)
    @player = @load_player() # Create replay and load the user's best score (from an id in the DOM)
    @others = @load_others() # Create replays from other players from DOM

  load_replay: ->
    options = @level.options

    if options.replay_only
      replay = new Replay(@level)
      replay.load(options.replay_file)
      return new Ghost(@level, replay)
    else
      return null

  load_player: ->
    options       = @level.options
    selector      = $(options.current_user)

    replay_id     = selector.attr(options.replay_id_attribute)
    replay_steps  = parseInt(selector.attr(options.replay_steps_attribute))
    replay_active = selector.find(options.replay_active_attribute) == 'true'

    if selector.length && replay_id.length > 0 && replay_active
      replay  = new Replay(@level)
      replay.load("#{replay_id}.replay")
      replay.steps = replay_steps
      return new Ghost(@level, replay)
    else
      return new Ghost(@level, null)

  load_others: ->
    others  = []
    options = @level.options

    load = (level, i) ->
      users = $(options.users)
      if users.length == 0
        setTimeout(( -> load(level, i+1)), (i*3.0/2.0)*100)
      else
        for user in users
          replay_id     = $(user).attr(options.replay_id_attribute)
          replay_steps  = parseInt($(user).attr(options.replay_steps_attribute))
          replay_active = $(user).attr(options.replay_active_attribute) == 'true'

          if replay_id.length > 0 && replay_active
            replay = new Replay(level)
            replay.load("#{replay_id}.replay")
            replay.steps = replay_steps
            others.push(new Ghost(level, replay))

    if $('#scores').length
      load(@level, 1) # Wait for async scores on page (AngularJS)

    return others

  display: ->
    if @player
      @player.display()

    if @replay
      @replay.display(false) # false means "not transparent"

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
