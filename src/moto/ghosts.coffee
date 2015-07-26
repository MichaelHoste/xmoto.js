class Ghosts

  constructor: (level) ->
    @level   = level
    @assets  = level.assets
    @options = level.options

    @player = {}
    @others = []

    @load_replays()

  load_assets: ->
    # Assets
    parts = [ Constants.torso, Constants.upper_leg, Constants.lower_leg,
              Constants.upper_arm, Constants.lower_arm,
              Constants.body, Constants.left_wheel, Constants.right_wheel,
              Constants.left_axle, Constants.right_axle ]
    for part in parts
      @assets.moto.push(part.ghost_texture)

  all_ghosts: ->
    ghosts = []
    ghosts = ghosts.concat(@others)
    ghosts.push(@player)
    ghosts

  init: ->
    for ghost in @all_ghosts()
      if ghost.replay
        ghost.init()

  reload: ->
    for ghost in @all_ghosts()
      if ghost.replay
        ghost.reload()

  move: ->
    for ghost in @all_ghosts()
      if ghost.replay
        ghost.move()

  display: ->
    for ghost in @all_ghosts()
      if ghost.replay
        ghost.display()

  load_replays: ->
    for option_replay in @options.replays
      replay = new Replay(@level)
      replay.load(option_replay.replay)

      if !@options.playable && option_replay.follow
        @player = new Ghost(@level, replay, false)
      else
        @others.push(new Ghost(@level, replay))
