AABB = planck.AABB

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

    @aabb = new AABB()

  init: ->
    if Constants.manual_scale
      @init_scroll()

    if Constants.debug_culling
      @culling = new PIXI.Graphics()
      @culling.label = 'culling (window)'
      @culling.alpha = 0.2
      @level.layers.translate_layer.addChild(@culling)

    @compute_aabb()

  active_object: ->
    if @level.options.playable
      @level.moto.body
    else
      @level.ghosts.player.moto.body

  move: ->
    if Constants.automatic_scale
      velocity = @active_object().getLinearVelocity()

      speed = Math2D.distance_between_points({x: 0, y: 0}, velocity)
      @scale.x = @scale.x * 0.995 + (Constants.default_scale.x / (1.0 + speed/7.5)) * 0.005
      @scale.y = @scale.y * 0.995 + (Constants.default_scale.y / (1.0 + speed/7.5)) * 0.005

      @translate.x = @translate.x * 0.97 + velocity.x/3.0 * 0.03
      @translate.y = @translate.y * 0.99 + velocity.y/3.0 * 0.01

    @compute_aabb()

  update: ->
    if Constants.debug_physics
      ctx = @level.debug_ctx

      ctx.save()

      ctx.translate(@options.width/2, @options.height/2) # Center of canvas
      ctx.scale(@scale.x, @scale.y)                      # Scale (zoom)
      ctx.translate(-@target().x, -@target().y)          # Camera on moto

      @level.physics.draw()

      ctx.restore()
    else
      t = @target()

      @level.layers.scale_layer.x = @options.width  / 2
      @level.layers.scale_layer.y = @options.height / 2

      @level.layers.scale_layer.scale.x = @scale.x
      @level.layers.scale_layer.scale.y = -@scale.y

      @level.layers.translate_layer.x = -t.x
      @level.layers.translate_layer.y = t.y

      # Containers for parallax scale/translate transforms
      delta_x     = 5 # Special delta so that x parallax is exactly the same as original XMOTO
      level_left  = @level.limits.player.left + delta_x
      level_top   = @level.limits.player.top
      aabb_factor = if Constants.debug_culling then 0.6 else 1.0

      for parallax, i in @level.layers.list
        scale_layer     = @level.layers.parallax_scale_layers[i]
        translate_layer = @level.layers.parallax_translate_layers[i]

        scale_layer.x = @options.width  / 2
        scale_layer.y = @options.height / 2

        # Blend between the camera's current scale and the default scale based on
        # parallax depth (z). z=1 (parallax=1,1) follows the camera zoom like the
        # main level; z=0 (distant parallax) keeps a constant default scale.
        z = (parallax.x + parallax.y) / 2.0
        effective_scale_x = z * @scale.x + (1.0 - z) * Constants.default_scale.x
        effective_scale_y = z * @scale.y + (1.0 - z) * Constants.default_scale.y

        scale_layer.scale.x =  effective_scale_x
        scale_layer.scale.y = -effective_scale_y

        # Half-viewport in this parallax layer's world coords, derived from its
        # effective scale (NOT the default scale — each layer has its own zoom).
        half_w = @options.width  / (2.0 * effective_scale_x)
        half_h = @options.height / (2.0 * Math.abs(effective_scale_y))

        # Anchored to the level's top-left corner so that parallax=1 matches the
        # main level (translate=(-t.x, t.y)) and parallax=0 stays frozen there.
        # The Y has an extra (1-parallax.y) * half_h correction because parallax
        # layers anchor at the viewport TOP edge, not its centre.
        translate_layer.x = -(level_left + parallax.x * (t.x - level_left))
        translate_layer.y =   level_top  + parallax.y * (t.y - level_top) - half_h * (1.0 - parallax.y)

        # Per-layer AABB in world coords, used by blocks/edges for visibility culling.
        # Centre matches the parallax viewport centre; size matches its effective scale.
        cx = -translate_layer.x
        cy =  translate_layer.y
        hw = half_w * aabb_factor
        hh = half_h * aabb_factor

        parallax.camera_aabb ?= new AABB()
        parallax.camera_aabb.lowerBound.set(cx - hw, cy - hh)
        parallax.camera_aabb.upperBound.set(cx + hw, cy + hh)

      # Opaque culling to see where sprites are "filtered out"
      if Constants.debug_culling
        size_x = @options.width  /  @scale.x * 0.6
        size_y = @options.height / -@scale.y * 0.6

        @culling.clear()
        @culling.rect(-size_x/2, -size_y/2, size_x, size_y)
        @culling.fill(0x333333)

        @culling.x = t.x
        @culling.y = -t.y

  # must be something with x and y values
  target: ->
    options  = @level.options
    position = @active_object().getPosition()

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
    factor = if Constants.debug_culling then 0.6 else 1.0

    size_x =   @options.width  * factor / @scale.x
    size_y = - @options.height * factor / @scale.y

    t = @target()

    half_w = size_x / 2
    half_h = size_y / 2

    @aabb.lowerBound.set(t.x - half_w, t.y - half_h)
    @aabb.upperBound.set(t.x + half_w, t.y + half_h)
