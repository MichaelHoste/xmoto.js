class Ghosts

  constructor: (level) ->
    @level   = level
    @assets  = level.assets
    @options = level.options

    @player = {}
    @others = []

    @load_replays()

  init: ->
    if @player.replay
      @player.init()

    # Assets
    parts = [ Constants.torso, Constants.upper_leg, Constants.lower_leg,
              Constants.upper_arm, Constants.lower_arm,
              Constants.body, Constants.left_wheel, Constants.right_wheel,
              Constants.left_axle, Constants.right_axle ]
    for part in parts
      @assets.moto.push(part.ghost_texture)

  reload: ->
    if @player.replay
      @player.reload()

  move: ->
    if @player.replay
      @player.move()

  display: ->
    if @player.replay
      @player.display()

  load_replays: ->
    for option_replay in @options.replays
      replay = new Replay(@level)
      replay.load(option_replay.file_or_string)
      replay.steps = option_replay.steps
      if option_replay.is_player
        @player = new Ghost(@level, replay)
      else
        @others << new Ghost(@level, replay)

    #others  = []
#
    #for option_replay in @options.replays
    #  replay_file  = option_replay.file
    #  replay_steps = option_replay.steps
#
    #  if replay_file.length > 0
    #    replay = new Replay(@level)
    #    replay.load("#{replay_file}")
    #    replay.steps = replay_steps
    #    others.push(new Ghost(@level, replay))
#
    #return others
