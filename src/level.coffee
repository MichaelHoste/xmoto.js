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

    # Engine sound
    @engine_sound  = new EngineSound(this)

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

    @start_time   = new Date().getTime()
    @current_time = 0

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
      @need_to_restart = false
      @restart(true)

    @current_time = new Date().getTime() - @start_time

    @init_canvas() if not @canvas_width
    @ctx.clearRect(0, 0, @canvas_width, @canvas_height)

    buffer_center_x = @buffer.canvas_width / 2
    canvas_center_x = @canvas_width / 2
    translate_x     = (@moto.position().x - @buffer.moto_position.x) * 70
    clipped_width   = @canvas_width  / (@scale.x / 70)
    margin_zoom_x   = (@canvas_width - clipped_width) / 2

    buffer_center_y = @buffer.canvas_height / 2
    canvas_center_y = @canvas_height / 2
    translate_y     = (@moto.position().y - @buffer.moto_position.y) * -70
    clipped_height  = @canvas_height / (@scale.y / -70)
    margin_zoom_y   = (@canvas_height - clipped_height) / 2

    @ctx.drawImage(@buffer.canvas,
                   buffer_center_x - canvas_center_x  + translate_x + margin_zoom_x, # The x coordinate where to start clipping
                   buffer_center_y - canvas_center_y  + translate_y + margin_zoom_y, # The y coordinate where to start clipping
                   clipped_width,                                                                                          # The width of the clipped image
                   clipped_height,                                                                                         # The height of the clipped image
                   0,                                                                                                      # The x coordinate where to place the image on the canvas
                   0,                                                                                                      # The y coordinate where to place the image on the canvas
                   @canvas_width,                                                                                          # The width of the image to use (stretch or reduce the image)
                   @canvas_height)                                                                                         # The height of the image to use (stretch or reduce the image)

    @ctx.save()

    # initialize position of camera
    @ctx.translate(@canvas_width/2, @canvas_height/2)               # Center of canvas
    @ctx.scale(@scale.x, @scale.y)                                  # Scale (zoom)
    @ctx.translate(-@moto.position().x, -@moto.position().y - 0.25) # Camera on moto

    # visible limits of the world (don't show anything outside of these limits)
    @visible =
      left:   @moto.position().x - (@canvas_width  / 2) / @scale.x
      right:  @moto.position().x + (@canvas_width  / 2) / @scale.x
      bottom: @moto.position().y + (@canvas_height / 2) / @scale.y
      top:    @moto.position().y - (@canvas_height / 2) / @scale.y
    @visible.aabb = new b2AABB()
    @visible.aabb.lowerBound.Set(@visible.left,  @visible.bottom)
    @visible.aabb.upperBound.Set(@visible.right, @visible.top)

    @entities.display_items(@ctx)
    @moto    .display(@ctx)
    @ghost   .display(@ctx) if @ghost

    @world.DrawDebugData() if debug

    @ctx.restore()

    # Save last step for replay
    @replay.add_frame()

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

    for entity in @entities.strawberries
      entity.display = true
