class Camera

  constructor: (level) ->
    @level  = level

    # level unities * scale = pixels
    @scale =
      x: Constants.default_scale.x
      y: Constants.default_scale.y

    # x and y offset on the target view
    @offset =
      x: 0
      y: 0

  init: ->
    if Constants.manual_scale
      @init_scroll()

  move: ->
    velocity = @level.moto.body.GetLinearVelocity()

    if Constants.automatic_scale
      speed = Math2D.distance_between_points(new b2Vec2(0, 0), velocity)
      @scale.x = @scale.x * 0.995 + (Constants.default_scale.x / (1.0 + speed/7.5)) * 0.005
      @scale.y = @scale.y * 0.995 + (Constants.default_scale.y / (1.0 + speed/7.5)) * 0.005

      @offset.x = @offset.x * 0.97 + velocity.x/3.0 * 0.03
      @offset.y = @offset.y * 0.99 + velocity.y/3.0 * 0.01

  # must be an something with x and y values
  target: ->
    options = @level.options
    if options.replay_mode
      position = @level.ghosts.replay.moto.body.GetPosition()
    else
      position = @level.moto.body.GetPosition()

    adjusted_position =
      x: position.x + @offset.x
      y: position.y + @offset.y

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
