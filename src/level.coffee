b2AABB = Box2D.Collision.b2AABB
b2Vec2 = Box2D.Common.Math.b2Vec2

class Level

  constructor: (renderer, options) ->
    @renderer = renderer
    @options  = options

    # Context
    @debug_ctx = $('#xmoto-debug').get(0).getContext('2d')
    @stage     = new PIXI.Container()

    # Level independant objects
    @assets        = new Assets()
    @camera        = new Camera(this)
    @physics       = new Physics(this)
    @input         = new Input(this)
    @listeners     = new Listeners(this)
    @moto          = new Moto(this)
    @particles     = new Particles(this)

    # Level dependent objects
    @infos         = new Infos(this)
    @sky           = new Sky(this)
    @blocks        = new Blocks(this)
    @limits        = new Limits(this)
    @layer_offsets = new LayerOffsets(this)
    @script        = new Script(this)
    @entities      = new Entities(this)

    # Replay: actual run of the player (not saved yet)
    @replay        = new Replay(this)

    # Ghosts: previous saved run of various players (included himself)
    @ghosts        = new Ghosts(this)

  load_from_file: (file_name, callback) ->
    $.ajax({
      type:     "GET",
      url:      "#{@options.levels_path}/#{file_name}",
      dataType: "xml",
      success:  (xml) -> @load_level(xml, callback)
      context:  @
    })

  load_level: (xml, callback) ->
    @infos        .parse(xml)
    @sky          .parse(xml)
    @blocks       .parse(xml)
    @limits       .parse(xml)
    @layer_offsets.parse(xml)
    @script       .parse(xml)
    @entities     .parse(xml)

    @sky     .load_assets()
    @blocks  .load_assets()
    @limits  .load_assets()
    @entities.load_assets()
    @moto    .load_assets()
    @ghosts  .load_assets()

    @assets.load(callback)

  init: ->
    @sky      .init()
    @limits   .init()
    @entities .init()
    @blocks   .init()
    @moto     .init()
    @ghosts   .init()
    @physics  .init()
    @input    .init()
    @camera   .init()
    @listeners.init()

    @init_timer()

  update: ->
    dead_player = @options.playable  && !@moto.dead
    dead_replay = !@options.playable && !@ghosts.player.moto.dead

    @update_timer() if dead_player || dead_replay

    @sky      .display()
    @entities .display()
    @camera   .display()
    @moto     .display() if @options.playable
    @ghosts   .display()
    @particles.display()

  init_timer: ->
    @start_time   = new Date().getTime()
    @current_time = 0

  update_timer: (update_now = false) ->
    new_time = new Date().getTime() - @start_time

    if update_now or Math.floor(new_time/10) > Math.floor(@current_time/10)
      minutes = Math.floor(new_time / 1000 / 60)
      seconds = Math.floor(new_time / 1000) % 60
      seconds = "0#{seconds}" if seconds < 10
      cents   = Math.floor(new_time / 10) % 100
      cents   = "0#{cents}" if cents < 10
      $(@options.chrono).text("#{minutes}:#{seconds}:#{cents}")

    @current_time = new_time

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
    @update_timer(true)
