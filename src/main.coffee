$.xmoto = (level_filename, options = {}) ->
  initialize = ->
    options = load_options(options)

    renderer = new PIXI.WebGLRenderer(options.width, options.height, {
      antialias:       true,
      backgroundColor: 0xFFFFFF
    })

    bind_render_to_dom(renderer, options)

    create_main_loop(level_filename, renderer, options)

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

  create_main_loop = (level_filename, renderer, options) ->
    level = new Level(renderer, options)

    level.load_from_file(level_filename, =>
      level.init(renderer)

      window.cancelAnimationFrame(window.game_loop)
      $(options.loading).hide()

      update = =>
        #console.log level.camera.container2.children.length
        level.physics.update()
        level.display()
        window.game_loop = requestAnimationFrame(update)
        renderer.render(level.stage)

      update()
    )

  initialize()

#full_screen = ->
#  window.onresize = ->
#    $("#xmoto").width($("body").width())
#    $("#xmoto").height($("body").height())
#  window.onresize()
