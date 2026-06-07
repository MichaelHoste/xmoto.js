class Level

  constructor: (renderer, options) ->
    @renderer = renderer
    @options  = options

    # Context
    @debug_ctx = $('#xmoto-debug').get(0).getContext('2d')
    @stage     = new PIXI.Container()

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
    @sky          = new Sky(this)
    @layers       = new Layers(this)
    @blocks       = new Blocks(this)
    @limits       = new Limits(this)
    @script       = new Script(this)
    @entities     = new Entities(this)

    # Replay: actual run of the player (not saved yet)
    @replay = new Replay(this)

    # Ghosts: previous saved run of various players (included himself)
    @ghosts = new Ghosts(this)

    # Manage fullscreen on/off
    @bind_fullscreen_change()

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

  init_timer: ->
    @start_time = new Date().getTime() # in ms

  update_timer: ->
    new_time = new Date().getTime() - @start_time
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

  toggle_fullscreen: ->
    if document.fullscreenElement
      document.exitFullscreen()
    else
      document.querySelector(@options.container).requestFullscreen()

  bind_fullscreen_change: ->
    $(document).on('fullscreenchange webkitfullscreenchange mozfullscreenchange MSFullscreenChange', =>
      if document.fullscreenElement
        @renderer._orig_width  = @options.width
        @renderer._orig_height = @options.height
        @renderer._orig_zoom   = Constants.default_scale.x

        screenW = screen.width
        screenH = screen.height

        @renderer.resize(screenW, screenH)

        @options.width  = screenW
        @options.height = screenH

        debugCanvas = document.getElementById('xmoto-debug')
        if debugCanvas
          debugCanvas.width  = screenW
          debugCanvas.height = screenH

        ratio      = Math.min(screenW / @renderer._orig_width, screenH / @renderer._orig_height)
        new_zoom_x =  @renderer._orig_zoom * ratio
        new_zoom_y = -@renderer._orig_zoom * ratio

        Constants.default_scale = { x: new_zoom_x, y: new_zoom_y }
        @camera.scale.x = new_zoom_x
        @camera.scale.y = new_zoom_y
      else
        @renderer.resize(@renderer._orig_width, @renderer._orig_height)
        @options.width  = @renderer._orig_width
        @options.height = @renderer._orig_height

        debugCanvas = document.getElementById('xmoto-debug')
        if debugCanvas
          debugCanvas.width  = @renderer._orig_width
          debugCanvas.height = @renderer._orig_height

        Constants.default_scale = { x: @renderer._orig_zoom, y: -@renderer._orig_zoom }
        @camera.scale.x = @renderer._orig_zoom
        @camera.scale.y = -@renderer._orig_zoom
    )
