$.xmoto = (level_filename, options = {}) ->
  initialize = (options) ->
    defaults =

      # Selectors
      canvas:       '#xmoto'         # canvas selector
      loading:      '#loading'       # loading selector
      chrono:       '#chrono'        # chrono selector
      users:        '#users .user'   # each $("#users .user") behaves like $('#current-user') (cf. below)
      current_user: '#current-user'  # ex. $("#current-user").attr('data-replay-id')
                                     #     must give the id from the current user's best score
                                     #     so that we can load the corresponding replay

      # Replay
      replay_only: false             # Not playable, just watch replay from replay_file
      replay_file: ''                # play "replay" file (not playable)

      # Zoom
      zoom: Constants.default_scale.x # Zoom of camera

      # Attributes
      replay_id_attribute:      'data-replay-id'      # id of replay (ex. /data/Replays/{id}.replay
      replay_steps_attribute:   'data-replay-steps'   # number of steps of replay
      replay_name_attribute:    'data-replay-name'    # name of user that made the replay
      replay_picture_attribute: 'data-replay-picture' # picture of user that made the replay
      replay_active_attribute:  'data-replay-display' # true if replay must be activated (displayed)

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
