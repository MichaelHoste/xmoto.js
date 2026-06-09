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

    @aabb = new Box2D.Collision.b2AABB()

  init: ->
    if Constants.manual_scale
      @init_scroll()

    if Constants.debug_clipping
      @clipping = new PIXI.Graphics()
      @clipping.alpha = 0.2
      @level.layers.translate_layer.addChild(@clipping)

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
    if Constants.debug_physics
      ctx = @level.physics.debug_ctx

      ctx.save()

      ctx.translate(@options.width/2, @options.height/2) # Center of canvas
      ctx.scale(@scale.x, @scale.y)                      # Scale (zoom)
      ctx.translate(-@target().x, -@target().y)          # Camera on moto

      @level.physics.world.DrawDebugData()

      ctx.restore()
    else
      t = @target()

      @level.layers.scale_layer.x = @options.width/2
      @level.layers.scale_layer.y = @options.height/2

      @level.layers.scale_layer.scale.x = @scale.x
      @level.layers.scale_layer.scale.y = -@scale.y

      @level.layers.translate_layer.x = -t.x
      @level.layers.translate_layer.y = t.y

      level_left = @level.limits.player.left
      level_top  = @level.limits.player.top

      half_w = (@aabb.upperBound.x - @aabb.lowerBound.x) / 2
      half_h = (@aabb.upperBound.y - @aabb.lowerBound.y) / 2

      # cy correction uses the base (unfactored) half-height — position must not shift when
      # debug_clipping is toggled. The AABB and overlay shrink to 60% when debug_clipping is on.
      default_half_w = @options.width  / (2.0 * Math.abs(Constants.default_scale.x))
      default_half_h = @options.height / (2.0 * Math.abs(Constants.default_scale.y))
      factor         = if Constants.debug_clipping then 0.6 else 1.0

      for parallax, i in @level.layers.list
        cx = level_left + parallax.x * (t.x - level_left)
        cy = level_top  + parallax.y * (t.y - level_top) - default_half_h * (1.0 - parallax.y)

        # Container: world-to-screen transform at fixed default scale (zoom-independent)
        container = @level.layers.parallax_containers[i]
        container.x       = @options.width  / 2
        container.y       = @options.height / 2
        container.scale.x =  Constants.default_scale.x
        container.scale.y = -Constants.default_scale.y

        # Parallax: parallax camera position
        @level.layers.parallax[i].x = -cx
        @level.layers.parallax[i].y = cy

        # AABB shrinks to 60% when debug_clipping is on (matching the main camera behaviour)
        hw = default_half_w * factor
        hh = default_half_h * factor
        parallax.aabb ?= new Box2D.Collision.b2AABB()
        parallax.aabb.lowerBound.Set(cx - hw, cy - hh)
        parallax.aabb.upperBound.Set(cx + hw, cy + hh)

      # Opaque clipping to see where sprites are "filtered out"
      if Constants.debug_clipping
        size_x = @options.width  /  @scale.x * 0.6
        size_y = @options.height / -@scale.y * 0.6

        @clipping.clear()
        @clipping.rect(-size_x/2, -size_y/2, size_x, size_y)
        @clipping.fill(0x333333)

        @clipping.x = t.x
        @clipping.y = -t.y

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

      return event.preventDefault() && false # defensive for old browsers

    # Add scroll to game div container
    container = $(@level.options.container)[0]
    container.addEventListener('DOMMouseScroll', scroll, false)
    container.addEventListener('mousewheel',     scroll, false)

  compute_aabb: ->
    factor = if Constants.debug_clipping then 0.6 else 1.0

    size_x =   @options.width  * factor / @scale.x
    size_y = - @options.height * factor / @scale.y

    t = @target()

    half_w = size_x / 2
    half_h = size_y / 2

    @aabb.lowerBound.Set(t.x - half_w, t.y - half_h)
    @aabb.upperBound.Set(t.x + half_w, t.y + half_h)
