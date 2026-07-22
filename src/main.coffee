$.xmoto = (level_filename, options = {}) ->
  initialize = ->
    options = load_options(options)

    renderer = await PIXI.autoDetectRenderer({
      preference:            'webgl', # or 'webgpu' or 'canvas'
      width:                 options.width,
      height:                options.height,
      background:            0xFFFFFF,
      clearBeforeRender:     false, # No need to clear, we paint the entire canvas
      textureGCActive:       false, # We manage texture GC manually (`renderer.gc.enabled` can be toggled)
      powerPreference:       'high-performance' # Hint for GPU power preference (WebGL & WebGPU).
      #antialias:             true  # Default to "false" for performance, but it doesn't seem to impact a lot, and way better rendering! (disable if needed)
      #preserveDrawingBuffer: true  # Need to be true when capturing with "toDataUrl" (may have low performance impact)
      #transparent: true            # May be useful later (moto on website)
    })

    window.cancelAnimationFrame(window.game_loop)

    bind_render_to_dom(renderer, options)
    main_loop(level_filename, renderer, options)

  load_options = (options) ->
    defaults =

      # Selectors
      container: '#xmoto'   # empty div where the game will be created
      loading:   '#loading' # loading selector
      chrono:    '#chrono'  # chrono selector

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
    container = $(options.container)

    container.find('canvas').remove()         # Remove old canvas
    $(options.loading).show()                 # Start loading
    container.css('height', options.height)   # Force height of parent
    container[0].appendChild(renderer.canvas) # Add PixiJS canvas to container
    debug_canvas_html = '<canvas id="xmoto-debug" width="' + options.width + '" height="' + options.height + '"></canvas>'
    container.append(debug_canvas_html)       # Add debug canvas to container (physics)
    $('#xmoto-debug').hide()                  # Hide debug canvas

  bind_stats_fps = (container_selector) ->
    stats = new Stats()
    stats.showPanel(0) # 0: fps, 1: ms, 2: mb, 3+: custom
    $(container_selector)[0].appendChild(stats.dom)
    $(container_selector).find('div:last').addClass('stats-fps')
    stats

  bind_stats_ms = (container_selector) ->
    stats = new Stats()
    stats.showPanel(1) # 0: fps, 1: ms, 2: mb, 3+: custom
    $(container_selector)[0].appendChild(stats.dom)
    $(container_selector).find('div:last').addClass('stats-ms')
    stats

  main_loop = (level_filename, renderer, options) ->
    container_selector = $(options.container)

    stats_fps = bind_stats_fps(container_selector) if Constants.debug
    stats_ms  = bind_stats_ms(container_selector)  if Constants.debug

    level = new Level(renderer, options)

    level.load_from_file(level_filename, =>
      level.init(renderer)
      $(options.loading).hide()

      update = =>
        stats_fps.begin() if Constants.debug
        stats_ms.begin()  if Constants.debug

        level.update()
        renderer.render(level.stage, { clear: false }) if !Constants.debug_physics
        window.game_loop = requestAnimationFrame(update)

        stats_fps.end() if Constants.debug
        stats_ms.end()  if Constants.debug

      update()
    )

  initialize()
