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
