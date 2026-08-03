class Level

  constructor: (renderer, options) ->
    @renderer = renderer
    @options  = options

    @show_loading()

    # Context
    @debug_ctx   = $('#xmoto-debug')[0].getContext('2d')
    @stage       = new PIXI.Container()
    @stage.label = @options.container # id of div

    # Debug
    @init_debug_physics()
    @init_devtools()

    # Level independant objects
    @assets    = new Assets()
    @camera    = new Camera(this)
    @physics   = new Physics(this)
    @input     = new Input(this)
    @listeners = new Listeners(this)
    @moto      = new Moto(this)
    @particles = new Particles(this)

    # Level dependent objects
    @infos        = new Infos(this)
    @replacements = new Replacements(this)
    @layers       = new Layers(this)
    @sky          = new Sky(this)
    @blocks       = new Blocks(this)
    @limits       = new Limits(this)
    @script       = new Script(this)
    @entities     = new Entities(this)

    # Replay: actual run of the player (not saved yet)
    @replay = new Replay(this)

    # Ghosts: previous saved run of various players (included himself)
    @ghosts = new Ghosts(this)

    # Manage fullscreen on/off
    @bind_fullscreen()

  load_from_file: (filename, callback) ->
    @assets.parse_theme( =>
      $.ajax({
        type:     "GET",
        url:      "#{@options.levels_path}/#{filename}",
        dataType: "xml",
        success:  (xml) -> @load_level(xml, callback)
        context:  @
      })
    )

  load_level: (xml, callback) ->
    @infos       .parse(xml)
    @replacements.parse(xml)
    @sky         .parse(xml)
    @layers      .parse(xml)
    @blocks      .parse(xml)
    @limits      .parse(xml)
    @script      .parse(xml)
    @entities    .parse(xml)

    @sky     .load_assets()
    @blocks  .load_assets()
    @limits  .load_assets()
    @entities.load_assets()
    @moto    .load_assets()
    @ghosts  .load_assets()

    @assets.load(callback)

  init: ->
    @sky      .init()
    @layers   .init()
    @blocks   .init()
    @limits   .init()
    @entities .init()
    @moto     .init()
    @ghosts   .init()
    @physics  .init()
    @input    .init()
    @camera   .init()
    @listeners.init()

    @hide_loading()
    @show_level_name()
    @init_timer()

  update: ->
    @physics.update()

    live_player = @options.playable  && !@moto.dead
    live_replay = !@options.playable && !@ghosts.player.moto.dead

    @update_timer() if live_player || live_replay

    @sky      .update()
    @layers   .update()
    @limits   .update()
    @entities .update()
    @camera   .update()
    @blocks   .update()
    @moto     .update() if @options.playable
    @ghosts   .update()
    @particles.update()

  show_loading: ->
    $(@options.loading).show()

  hide_loading: ->
    $(@options.loading).hide()

  show_level_name: ->
    selector = $(@options.level_name)
    selector.text(@infos.name)

    # Force animation refresh
    selector.removeClass('fade-out')
    selector[0].offsetWidth
    selector.addClass('fade-out')

  init_timer: ->
    @start_time = performance.now() # in ms

  update_timer: ->
    new_time = performance.now() - @start_time
    elapsed  = Math.floor(new_time / 10)
    minutes  = Math.floor(elapsed / 6000)
    seconds  = Math.floor(elapsed / 100) % 60
    cents    = elapsed % 100

    text = "#{@pad(seconds)}:#{@pad(cents)}"
    text = "#{minutes}:#{text}" if minutes > 0 # show minutes only if needed

    $(@options.chrono).text(text)

  pad: (n) ->
    String(n).padStart(2, '0')

  got_strawberries: ->
    for strawberry in @entities.strawberries
      if strawberry.display
        return false
    return true

  respawn_strawberries: ->
    for entity in @entities.strawberries
      entity.display = true

  restart: ->
    @replay = new Replay(this)

    @ghosts.reload()

    @moto.destroy()
    @moto = new Moto(this)
    @moto.init()

    @respawn_strawberries()

    @init_timer()
    @update_timer()

  init_debug_physics: ->
    if Constants.debug_physics
      $("#{@options.container} > canvas").hide()
      $('#xmoto-debug').show()

  # To debug the stage in Chrome: https://pixijs.io/devtools/
  init_devtools: ->
    window.__PIXI_DEVTOOLS__ =
      stage:    @stage
      renderer: @renderer

  toggle_fullscreen: ->
    if document.fullscreenElement
      document.exitFullscreen()
    else
      $(@options.container)[0].requestFullscreen()

  bind_fullscreen: ->
    $(document).on('fullscreenchange webkitfullscreenchange mozfullscreenchange MSFullscreenChange', =>
      debug_canvas = $('#xmoto-debug')[0]

      if document.fullscreenElement
        @original_width   = @options.width
        @original_height  = @options.height
        @original_scale_x = Constants.default_scale.x
        @original_scale_y = Constants.default_scale.y

        @renderer.resize(screen.width, screen.height)

        @options.width  = screen.width
        @options.height = screen.height

        if debug_canvas
          debug_canvas.width   = screen.width
          debug_canvas.height  = screen.height
          @debug_ctx.lineWidth = 0.03 # must be redefined

        ratio       = Math.min(screen.width / @original_width, screen.height / @original_height)
        new_scale_x = @original_scale_x * ratio
        new_scale_y = @original_scale_y * ratio

        Constants.default_scale = { x: new_scale_x, y: new_scale_y }
        @camera.scale.x = new_scale_x
        @camera.scale.y = new_scale_y
      else
        @renderer.resize(@original_width, @original_height)
        @options.width  = @original_width
        @options.height = @original_height

        if debug_canvas
          debug_canvas.width   = @original_width
          debug_canvas.height  = @original_height
          @debug_ctx.lineWidth = 0.03 # must be redefined

        Constants.default_scale = { x: @original_scale_x, y: @original_scale_y }
        @camera.scale.x = @original_scale_x
        @camera.scale.y = @original_scale_y
    )
