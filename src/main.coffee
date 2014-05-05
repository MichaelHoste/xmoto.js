window.debug1 = ""
window.debug2 = ""

$.xmoto = (level_filename, options = {}) ->
  initialize = (options) ->
    defaults =

      # Selectors
      canvas:       '#xmoto'          # canvas selector
      loading:      '#loading'        # loading selector
      chrono:       '#chrono'         # chrono selector

      # Best replay from current user
      best_score_file:  ''
      best_score_steps: 99999999999
      best_score_ghost: true          # Always show ghost for best score

      # Replays
      replays: []                     # [ {file: , steps: , name: , picture: }, ... ]

      # Replay mode
      replay_mode: false              # Not playable, just watch replay from replay_file
      replay_file: ''                 # "replay" file (not playable) (ex. "4.replay")

      # Zoom
      zoom: Constants.default_scale.x # Zoom of camera

      # Paths
      levels_path:  '/data/Levels'        # Path where are the levels (ex. /data/Levels/l1.lvl)
      scores_path:  '/level_user_links'   # Path where to POST a score
      replays_path: '/data/Replays'       # Path where all the replay files are stored (ex. /data/Replays/1.replay)

    return $.extend(defaults, options)

  options = initialize(options)
  Constants.default_scale =
    x:  options.zoom
    y: -options.zoom

  $(options.loading).show()

  level = new Level(options)
  level.load_from_file(level_filename)
  level.assets.load( ->
    update = ->
      level.physics.update()
      level.display()
      window.game_loop = window.requestAnimationFrame(update)

    level.start_time   = new Date().getTime()
    level.current_time = 0
    level.physics.init()

    window.cancelAnimationFrame(window.game_loop)
    $(options.loading).hide()

    update()
  )

#full_screen = ->
#  window.onresize = ->
#    $("#xmoto").width($("body").width())
#    $("#xmoto").height($("body").height())
#  window.onresize()
