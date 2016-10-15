class Camera

  constructor: (level) ->
    @level   = level
    @options = level.options

    # level unities * scale = pixels
    @scale =
      x: Constants.default_scale.x
      y: Constants.default_scale.y

    # x and y translate on the target view
    @translate =
      x: 0
      y: 0

    @scale_container     = new PIXI.Container()
    @translate_container = new PIXI.Container()

    @level.stage.addChild(@scale_container)
    @scale_container.addChild(@translate_container)

  init: ->
    if Constants.manual_scale
      @init_scroll()

    if Constants.debug
      $('#xmoto canvas').hide()
      $('#xmoto-debug').show()

    #
    # @frame = new PIXI.Graphics()
    # @frame.alpha = 0.2
    # @translate_container.addChild(@frame)
    #

    @aabb = @compute_aabb()

  active_object: ->
    if @level.options.playable
      @level.moto.body
    else
      @level.ghosts.player.moto.body

  move: ->
    if Constants.automatic_scale
      velocity = @active_object().GetLinearVelocity()

      speed = Math2D.distance_between_points(new b2Vec2(0, 0), velocity)
      @scale.x = @scale.x * 0.995 + (Constants.default_scale.x / (1.0 + speed/7.5)) * 0.005
      @scale.y = @scale.y * 0.995 + (Constants.default_scale.y / (1.0 + speed/7.5)) * 0.005

      @translate.x = @translate.x * 0.97 + velocity.x/3.0 * 0.03
      @translate.y = @translate.y * 0.99 + velocity.y/3.0 * 0.01

      @aabb = @compute_aabb()

  update: ->
    if Constants.debug
      ctx = @level.physics.debug_ctx

      ctx.save()

      ctx.translate(@options.width/2, @options.height/2) # Center of canvas
      ctx.scale(@scale.x, @scale.y)                      # Scale (zoom)
      ctx.translate(-@target().x, -@target().y)          # Camera on moto

      @level.physics.world.DrawDebugData()

      ctx.restore()
    else
      @scale_container.x = @options.width/2
      @scale_container.y = @options.height/2

      @scale_container.scale.x = @scale.x
      @scale_container.scale.y = -@scale.y

      @translate_container.x = -@target().x
      @translate_container.y = @target().y

      # #
      # @frame.clear()
      # @frame.beginFill(0x333333)

      # size_x = (@options.width  / 100.0) * (60.0  / @scale.x)
      # size_y = (@options.height / 100.0) * (-60.0 / @scale.y)

      # @frame.drawRect(-size_x/2, -size_y/2, size_x, size_y)
      # @frame.x = @target().x
      # @frame.y = -@target().y
      # #

  # must be something with x and y values
  target: ->
    options  = @level.options
    position = @active_object().GetPosition()

    adjusted_position =
      x: position.x + @translate.x
      y: position.y + @translate.y + 0.25

  # If there are some issues on other systems than MacOS,
  # check this to find a solution : http://stackoverflow.com/questions/5527601/normalizing-mousewheel-speed-across-browsers
  init_scroll : ->
    scroll = (event) =>
      if event.wheelDelta
        delta = event.wheelDelta/40
      else if event.detail
        delta = -event.detail
      else
        delta = 0

      # zoom / dezoom
      @scale.x += (@scale.x/200) * delta
      @scale.y += (@scale.y/200) * delta

      # boundaries
      min_limit_x = Constants.default_scale.x / 2
      min_limit_y = Constants.default_scale.y / 2

      max_limit_x = Constants.default_scale.x * 2
      max_limit_y = Constants.default_scale.y * 2

      @scale.x = min_limit_x if @scale.x < min_limit_x
      @scale.y = min_limit_y if @scale.y > min_limit_y

      @scale.x = max_limit_x if @scale.x > max_limit_x
      @scale.y = max_limit_y if @scale.y < max_limit_y

      return event.preventDefault() && false

    canvas = $(@level.options.canvas).get(0)
    canvas.addEventListener('DOMMouseScroll', scroll, false)
    canvas.addEventListener('mousewheel',     scroll, false)

  compute_aabb: ->
    size_x =   @options.width  * 1.0 / @scale.x
    size_y = - @options.height * 1.0 / @scale.y

    aabb = new b2AABB()
    aabb.lowerBound.Set(@target().x - size_x/2, @target().y - size_y/2)
    aabb.upperBound.Set(@target().x + size_x/2, @target().y + size_y/2)
    return aabb

  compute_aabb_for_frame: ->
    size_x =   @options.width  * 0.6 / @scale.x
    size_y = - @options.height * 0.6 / @scale.y

    aabb = new b2AABB()
    aabb.lowerBound.Set(@target().x - size_x/2, @target().y - size_y/2)
    aabb.upperBound.Set(@target().x + size_x/2, @target().y + size_y/2)
    return aabb
