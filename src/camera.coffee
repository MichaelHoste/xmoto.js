class Camera

  constructor: (level) ->
    @level   = level
    @options = level.options

    # level unities * scale = pixels
    @scale =
      x: Constants.default_scale.x
      y: Constants.default_scale.y

    # x and y offset on the target view
    @offset =
      x: 0
      y: 0

    @container  = new PIXI.Container()
    @container2 = new PIXI.Container()

    @container.addChild(@container2)
    @level.stage.addChild(@container)

  init: ->
    if Constants.manual_scale
      @init_scroll()

    @frame = new PIXI.Graphics()
    @frame.alpha = 0.2
    @container2.addChild(@frame)

    @aabb = @compute_aabb()
    console.log @aabb
    console.log '-'

  active_object: ->
    if @level.options.playable
      @level.moto.body
    else
      @level.ghosts.player.moto.body

  move: ->
    velocity = @active_object().GetLinearVelocity()

    if Constants.automatic_scale
      speed = Math2D.distance_between_points(new b2Vec2(0, 0), velocity)
      @scale.x = @scale.x * 0.995 + (Constants.default_scale.x / (1.0 + speed/7.5)) * 0.005
      @scale.y = @scale.y * 0.995 + (Constants.default_scale.y / (1.0 + speed/7.5)) * 0.005

      @offset.x = @offset.x * 0.97 + velocity.x/3.0 * 0.03
      @offset.y = @offset.y * 0.99 + velocity.y/3.0 * 0.01

    @aabb = @compute_aabb()

  display: ->
    if Constants.debug
      $('#xmoto canvas').hide()
      $('#xmoto-debug').show()

      ctx = @level.physics.debug_ctx

      ctx.save()

      ctx.translate(@options.width/2, @options.height/2) # Center of canvas
      ctx.scale(@scale.x, @scale.y)                      # Scale (zoom)
      ctx.translate(-@target().x, -@target().y)          # Camera on moto

      @level.physics.world.DrawDebugData()

      ctx.restore()
    else
      @container.x = @options.width/2
      @container.y = @options.height/2

      @container.scale.x = @scale.x
      @container.scale.y = -@scale.y

      @container2.x = -@target().x
      @container2.y = @target().y

      @frame.clear()
      @frame.beginFill(0x333333)

      size_x = (@options.width  / 100.0) * (Constants.default_scale.x / @scale.x)
      size_y = (@options.height / 100.0) * (Constants.default_scale.y / @scale.y)

      @frame.drawRect(-size_x/2, -size_y/2, size_x, size_y, 0.1)
      @frame.x = @target().x
      @frame.y = -@target().y

  # must be something with x and y values
  target: ->
    options  = @level.options
    position = @active_object().GetPosition()

    adjusted_position =
      x: position.x + @offset.x
      y: position.y + @offset.y + 0.25

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
    size_x = (@options.width  / 100.0) * (Constants.default_scale.x / @scale.x)
    size_y = (@options.height / 100.0) * (Constants.default_scale.y / @scale.y)

    aabb = new b2AABB()
    aabb.lowerBound.Set(@target().x - size_x/2, @target().y - size_y/2)
    aabb.upperBound.Set(@target().x + size_x/2, @target().y + size_y/2)
    return aabb
