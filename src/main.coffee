$.xmoto = (level_filename, options = {}) ->
  initialize = ->
    options = load_options(options)

    # To make sprites of moto more "sharp" (less blurry),
    # we disable midmapping. It may impact rendering speed
    # because midmap generate lower images to speed up
    # rendering  (only for pow2 sizes)
    PIXI.settings.MIPMAP_TEXTURES = PIXI.MIPMAP_MODES.OFF

    # If midmapping is enabled, sharper rendering is done using
    # this line (maybe blurrier is better? Need to test on bike)
    # PIXI.settings.SCALE_MODE = PIXI.SCALE_MODES.NEAREST

    renderer = new PIXI.Renderer({
      width:                 options.width,
      height:                options.height,
      backgroundColor:       0xFFFFFF,
      clearBeforeRender:     false  # Should be faster (because we always render everything)
      preserveDrawingBuffer: true   # Need to be true if clearBeforeRender is false

      #transparent:     true  # May be useful later (moto on website)
      #antialias:       true, # antiliasing is false by default and we keep it that way because
                              # of significative FPS drop and small visual changes
    })

    window.cancelAnimationFrame(window.game_loop)

    bind_render_to_dom(renderer, options)
    main_loop(level_filename, renderer, options)

  load_options = (options) ->
    defaults =

      # Selectors
      canvas:  '#xmoto'   # canvas selector
      loading: '#loading' # loading selector
      chrono:  '#chrono'  # chrono selector

      # Size
      width:  800
      height: 600

      # Replays
      replays:  []   # [ { replay: , follow: , name: , picture: }, ... ]
      playable: true # if false, just watch replays

      # Zoom
      zoom: Constants.default_scale.x # Zoom of camera

      # Paths
      levels_path:  '/data/Levels'  # Path where are the levels (ex. /data/Levels/l1.lvl)
      scores_path:  '/scores'       # Path where to POST a score
      replays_path: '/data/Replays' # Path where all the replay files are stored (ex. /data/Replays/1.replay)

    options = $.extend(defaults, options)

    Constants.default_scale =
      x:  options.zoom
      y: -options.zoom

    return options

  bind_render_to_dom = (renderer, options) ->
    $("#xmoto canvas").remove()

    $(options.loading).show()
    $('#xmoto').css('height', options.height)
    $('#xmoto')[0].appendChild(renderer.view)
    $('#xmoto').append('<canvas id="xmoto-debug" width="' + options.width + '" height="' + options.height + '"></canvas>')
    $('#xmoto-debug').hide()

  bind_stats_fps = ->
    stats = new Stats()
    stats.showPanel(0) # 0: fps, 1: ms, 2: mb, 3+: custom
    $('#xmoto')[0].appendChild(stats.dom)
    $('#xmoto div:last').addClass('stats-fps')
    stats

  bind_stats_ms = ->
    stats = new Stats()
    stats.showPanel(1) # 0: fps, 1: ms, 2: mb, 3+: custom
    $('#xmoto')[0].appendChild(stats.dom)
    $('#xmoto div:last').addClass('stats-ms')
    stats

  main_loop = (level_filename, renderer, options) ->
    stats_fps = bind_stats_fps() if Constants.debug
    stats_ms  = bind_stats_ms()  if Constants.debug

    level = new Level(renderer, options)

    level.load_from_file(level_filename, =>
      level.init(renderer)
      $(options.loading).hide()

      update = =>
        stats_fps.begin() if Constants.debug
        stats_ms.begin()  if Constants.debug

        level.update()
        renderer.render(level.stage) if !Constants.debug_physics
        window.game_loop = requestAnimationFrame(update)

        stats_fps.end() if Constants.debug
        stats_ms.end()  if Constants.debug

      update()
    )

  initialize()

#full_screen = ->
#  window.onresize = ->
#    $("#xmoto").width($("body").width())
#    $("#xmoto").height($("body").height())
#  window.onresize()
