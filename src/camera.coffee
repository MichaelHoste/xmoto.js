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

    @scale_container      = new PIXI.Container()
    @translate_container  = new PIXI.Container()
    @negative_z_container = new PIXI.Container()
    @neutral_z_container  = new PIXI.Container()
    @positive_z_container = new PIXI.Container()

    @level.stage.addChild(@scale_container)
    @scale_container.addChild(@translate_container)
    @translate_container.addChild(@negative_z_container)
    @translate_container.addChild(@neutral_z_container)
    @translate_container.addChild(@positive_z_container)

  init: ->
    if Constants.manual_scale
      @init_scroll()

    if Constants.debug_physics
      $('#xmoto canvas').hide()
      $('#xmoto-debug').show()

    if Constants.debug_clipping
      @clipping = new PIXI.Graphics()
      @clipping.alpha = 0.2
      @translate_container.addChild(@clipping)

    @compute_aabb()

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

    @compute_aabb()

  update: ->
    #console.log(@target().x, @target().y)

    if Constants.debug_physics
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

      @translate_container.x = -$(window).width()/2/Constants.default_scale.x # 0 #-@target().x
      @translate_container.y = $(window).height()/2/Constants.default_scale.y # 0 #@target().y

      # Opaque clipping to see where sprites are "filtered out"
      if Constants.debug_clipping
        @clipping.clear()
        @clipping.beginFill(0x333333)

        size_x = (@options.width  / 100.0) * (60.0  / @scale.x)
        size_y = (@options.height / 100.0) * (-60.0 / @scale.y)

        @clipping.drawRect(-size_x/2, -size_y/2, size_x, size_y)
        @clipping.x = @target().x
        @clipping.y = -@target().y

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
    if Constants.debug_clipping
      @aabb = @aabb_for_clipping()
    else
      @aabb = @aabb_for_canvas()

  aabb_for_clipping: ->
    size_x =   @options.width  * 0.6 / @scale.x
    size_y = - @options.height * 0.6 / @scale.y

    aabb = new b2AABB()
    aabb.lowerBound.Set(@target().x - size_x/2, @target().y - size_y/2)
    aabb.upperBound.Set(@target().x + size_x/2, @target().y + size_y/2)
    return aabb

  aabb_for_canvas: ->
    size_x =   @options.width  * 1.0 / @scale.x
    size_y = - @options.height * 1.0 / @scale.y

    aabb = new b2AABB()
    aabb.lowerBound.Set(@target().x - size_x/2, @target().y - size_y/2)
    aabb.upperBound.Set(@target().x + size_x/2, @target().y + size_y/2)
    return aabb
