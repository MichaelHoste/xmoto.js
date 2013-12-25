b2AABB = Box2D.Collision.b2AABB
b2Vec2 = Box2D.Common.Math.b2Vec2

class Level

  constructor: ->
    # Context
    @canvas = $('#game').get(0)
    @ctx    = @canvas.getContext('2d')

    # level unities * scale = pixels
    @scale =
      x:  70
      y: -70

    # Assets manager
    @assets        = new Assets()

    # Box2D World
    @physics       = new Physics(this)
    @world         = @physics.world

    # Inputs
    @input         = new Input(this)

    # Listeners
    @listeners     = new Listeners(this)

    # Replay (for ghost)
    @replay        = new Replay(this)
    @ghost         = new Ghost(this, null)

    # Moto (level independant)
    @moto          = new Moto(this)

    # Level dependent objects
    @infos         = new Infos(this)
    @sky           = new Sky(this)
    @blocks        = new Blocks(this)
    @limits        = new Limits(this)
    @layer_offsets = new LayerOffsets(this)
    @script        = new Script(this)
    @entities      = new Entities(this)

    # Buffer
    @buffer        = new Buffer(this)

  load_from_file: (file_name) ->
    $.ajax({
      type:     "GET",
      url:      "data/Levels/#{file_name}",
      dataType: "xml",
      success:  @load_level
      async:    false
      context:  @
    })

  load_level: (xml) ->
    # Level dependent objects
    @infos        .parse(xml).init()
    @sky          .parse(xml).init()
    @blocks       .parse(xml).init()
    @limits       .parse(xml).init()
    @layer_offsets.parse(xml).init()
    @script       .parse(xml).init()
    @entities     .parse(xml).init()

    # Moto and ghosts (level independant)
    @moto.init()
    @ghost.init()

    @input.init()
    @listeners.init()

  init_canvas: ->
    @canvas_width  = parseFloat(@canvas.width)
    @canvas_height = parseFloat(@canvas.height)
    @ctx.lineWidth = 0.01

  display: (debug = false) ->
    if @need_to_restart
      @restart(true)

    @init_canvas() if not @canvas_width

    @update_timer()

    # visible screen limits of the world (don't show anything outside of these limits)
    @compute_visibility()

    @sky.display(@ctx)

    # Redraw buffer if needed (the buffer is bigger than the canvas)
    # And display it (copy the right pixels from the buffer to the canvas)
    @buffer.redraw() if @buffer.redraw_needed()
    @buffer.display()

    @ctx.save()

    # initialize position of camera
    @ctx.translate(@canvas_width/2, @canvas_height/2)               # Center of canvas
    @ctx.scale(@scale.x, @scale.y)                                  # Scale (zoom)
    @ctx.translate(-@object_to_follow().position().x, -@object_to_follow().position().y - 0.25) # Camera on moto

    # Display entities, moto and ghost (blocks etc. are already drawn from the buffer)
    @entities.display_items(@ctx)
    @moto    .display(@ctx)
    if @ghost
      @ghost.display(@ctx)
      @ghost.next_state()

    @world.DrawDebugData() if debug

    @ctx.restore()

    # Save last step for replay
    @replay.add_frame()

  update_timer: (now = false) ->
    new_time = new Date().getTime() - @start_time

    if now or Math.floor(new_time/10) > Math.floor(@current_time/10)
      minutes = Math.floor(new_time / 1000 / 60)
      seconds = Math.floor(new_time / 1000) % 60
      seconds = "0#{seconds}" if seconds < 10
      cents   = Math.floor(new_time / 10) % 100
      cents   = "0#{cents}" if cents < 10
      $("#chrono").text("#{minutes}:#{seconds}:#{cents}")

    @current_time = new_time

  compute_visibility: ->
    @visible =
      left:   @object_to_follow().position().x - (@canvas_width  / 2) / @scale.x
      right:  @object_to_follow().position().x + (@canvas_width  / 2) / @scale.x
      bottom: @object_to_follow().position().y + (@canvas_height / 2) / @scale.y
      top:    @object_to_follow().position().y - (@canvas_height / 2) / @scale.y
    @visible.aabb = new b2AABB()
    @visible.aabb.lowerBound.Set(@visible.left,  @visible.bottom)
    @visible.aabb.upperBound.Set(@visible.right, @visible.top)

  flip_moto: ->
    @moto = MotoFlip.execute(@moto)

  got_strawberries: ->
    for strawberry in @entities.strawberries
      if strawberry.display
        return false
    return true

  restart: (save_replay = false) ->
    if save_replay
      if (not @ghost.replay) or @ghost.replay.frames_count() > @replay.frames_count()
        @ghost  = new Ghost(this, @replay.clone())
    @ghost.current_frame = 0
    @replay = new Replay(this)

    @moto.destroy()
    @moto = new Moto(this, false)
    @moto.init()

    @start_time   = new Date().getTime()
    @current_time = 0
    @update_timer(true)

    for entity in @entities.strawberries
      entity.display = true

    @need_to_restart = false

  # time, in centiseconds
  gameTime: ->
    current_time = new Date().getTime()
    (current_time - @start_time) / 10

  object_to_follow: ->
    @moto
