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

    # Box2D physics
    @physics       = new Physics(this)

    # Inputs
    @input         = new Input(this)

    # Listeners
    @listeners     = new Listeners(this)

    # Replay: actual run of the player
    @replay        = new Replay(this)

    # Ghosts: previous saved run of various players (included himself)
    @ghosts        = new Ghosts(this)

    # Moto (level independant)
    @moto          = new Moto(this)

    # Particles (level independant)
    @particles     = new Particles(this)

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

    @render_mode   = "normal"

  load_from_file: (file_name) ->
    $.ajax({
      type:     "GET",
      url:      "/data/Levels/#{file_name}",
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
    @ghosts.init()

    @input.init()
    @listeners.init()

  init_canvas: ->
    @canvas_width  = parseFloat(@canvas.width)
    @canvas_height = parseFloat(@canvas.height)
    @ctx.lineWidth = 0.01

  display: ->
    @init_canvas() if not @canvas_width

    @update_timer()

    # visible screen limits of the world (don't show anything outside of these limits)
    @compute_visibility()

    @sky.display()

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
    @entities.display_items()
    @moto    .display()
    @ghosts  .display()

    @particles.display()

    @physics.display() if Constants.debug

    @ctx.restore()

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
    @moto = MotoFlipService.execute(@moto)

  got_strawberries: ->
    for strawberry in @entities.strawberries
      if strawberry.display
        return false
    return true

  restart: ->
    @replay = new Replay(this)

    @moto.destroy()
    @moto = new Moto(this, false)
    @moto.init()

    @start_time   = new Date().getTime()
    @current_time = 0
    @update_timer(true)

    for entity in @entities.strawberries
      entity.display = true

  object_to_follow: ->
    @moto
