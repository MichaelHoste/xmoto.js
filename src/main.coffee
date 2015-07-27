$.xmoto = (level_filename, options = {}) ->
  initialize = (options) ->
    defaults =

      # Selectors
      canvas:  '#xmoto'   # canvas selector
      loading: '#loading' # loading selector
      chrono:  '#chrono'  # chrono selector

      # Replays
      replays:  []   # [ { replay: , follow: , name: , picture: }, ... ]
      playable: true # if false, just watch replays

      # Zoom
      zoom: Constants.default_scale.x   # Zoom of camera

      # Paths
      levels_path:  '/data/Levels'  # Path where are the levels (ex. /data/Levels/l1.lvl)
      scores_path:  '/scores'       # Path where to POST a score
      replays_path: '/data/Replays' # Path where all the replay files are stored (ex. /data/Replays/1.replay)

    return $.extend(defaults, options)

  options = initialize(options)
  Constants.default_scale =
    x:  options.zoom
    y: -options.zoom

  $(options.loading).show()

  renderer = new PIXI.autoDetectRenderer(1000, 600, {
    antialias:       true,
    backgroundColor: 0xFFFFFF
  })

  $('#xmoto-pixi')[0].appendChild(renderer.view)

  level = new Level(options)
  level.load_from_file(level_filename)

  level.assets.load( =>
    level.init()

    window.cancelAnimationFrame(window.game_loop)
    $(options.loading).hide()

    update = =>
      level.physics.update()
      level.display()
      window.game_loop = requestAnimationFrame(update)
      renderer.render(level.stage)

    update()
  )

#full_screen = ->
#  window.onresize = ->
#    $("#xmoto").width($("body").width())
#    $("#xmoto").height($("body").height())
#  window.onresize()
