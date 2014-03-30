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
    options      = @level.options
    selector     = $(options.current_user)
    replay_id    = selector.attr(options.replay_id_attribute)

    if selector.length && replay_id.length > 0
      replay  = new Replay(@level)
      replay.load("#{replay_id}.replay")
      return new Ghost(@level, replay)
    else
      return new Ghost(@level, null)

  load_others: ->
    []

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
