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

  #create_background_buffer: ->
  #  @back_canvas = $('#back').get(0)
  #  @back_ctx    = @back_canvas.getContext('2d')
#
  #  @back_canvas_width  = parseFloat(@back_canvas.width)
  #  @back_canvas_height = parseFloat(@back_canvas.height)
  #  @back_ctx.lineWidth = 0.01
#
  #  @back_ctx.clearRect(0, 0, @back_canvas_width, @back_canvas_height)
  #  @back_ctx.save()
#
  #  # initialize position of camera
  #  @back_ctx.translate(@back_canvas_width/2, @back_canvas_height/2)     # Center of canvas
  #  @back_ctx.scale(@back_canvas_width / @limits.size.x, -@back_canvas_height / @limits.size.y)                                  # Scale (zoom)
#
  #  @sky     .display(@back_ctx)
  #  @limits  .display(@back_ctx)
  #  @entities.display_sprites(@back_ctx)
  #  @blocks  .display(@back_ctx)
#
  #  @back_ctx.restore()

  display: (debug = false) ->
    if @need_to_restart
      @need_to_restart = false
      @restart(true)

    @current_time = new Date().getTime() - @start_time

    @init_canvas() if not @canvas_width
    @ctx.clearRect(0, 0, @canvas_width, @canvas_height)

    #@ctx.drawImage(@back_canvas, 0, 0, 1000, 400)
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

    @sky     .display(@ctx)
    @limits  .display(@ctx)
    @entities.display_sprites(@ctx)
    @blocks  .display(@ctx)
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
