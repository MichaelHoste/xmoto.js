b2AABB = Box2D.Collision.b2AABB
b2Vec2 = Box2D.Common.Math.b2Vec2

class Buffer

  constructor: (level) ->
    @level  = level

    # Create buffer on DOM
    buffer_html = "<canvas id=\"buffer\"
                           width=\"#{parseFloat(@level.canvas.width)*1.5}\"
                           height=\"#{parseFloat(@level.canvas.height)*1.5}\"
                           style=\"display:none\">
                   </canvas>"
    $(buffer_html).insertAfter(@level.options.canvas)

    # Buffer context
    @canvas = $("#buffer").get(0)
    @ctx    = @canvas.getContext('2d')

    # can start at any size, but we prefer to be close to default scale
    # of the main canvas for better image quality
    @buffer_scale =
      x: @level.camera.scale.x
      y: @level.camera.scale.y

    @scale        = @level.camera.scale
    @sky          = @level.sky
    @limits       = @level.limits
    @entities     = @level.entities
    @blocks       = @level.blocks

  init_canvas: ->
    @canvas_width  = parseFloat(@canvas.width)
    @canvas_height = parseFloat(@canvas.height)

  redraw_needed: ->
    if not @canvas_width
      return true

    if @visible
      moto = @level.object_to_follow()
      return true if @visible.right  < moto.position().x + (@level.canvas_width/2)  / @scale.x
      return true if @visible.left   > moto.position().x - (@level.canvas_width/2)  / @scale.x
      return true if @visible.top    < moto.position().y - (@level.canvas_height/2) / @scale.y
      return true if @visible.bottom > moto.position().y + (@level.canvas_height/2) / @scale.y

    false

  redraw: ->
    moto = @level.object_to_follow()

    @init_canvas() if not @canvas_width

    # Save moto position at the moment the buffer is redrawn
    @moto_position =
      x: moto.position().x
      y: moto.position().y

    # Define buffer scale at the moment of the redrawn
    # (minimum the value of the default zoom, or else the quality is too high and better have a bigger buffer)
    @buffer_scale =
      x: if @scale.x > Constants.default_scale.x then Constants.default_scale.x else @scale.x
      y: if @scale.y < Constants.default_scale.y then Constants.default_scale.y else @scale.y

    # visible screen limits of the world
    # (don't show anything outside of these limits when the buffer redraw)
    @compute_visibility()

    @ctx.clearRect(0, 0, @canvas_width, @canvas_height)
    @ctx.save()

    # initialize position of camera
    @ctx.translate(@canvas_width/2, @canvas_height/2)             # Center of canvas
    @ctx.scale(@buffer_scale.x, @buffer_scale.y)                  # Scale (zoom)
    @ctx.translate(-moto.position().x, -moto.position().y - 0.25) # Camera on moto

    # Display limits, entities and blocks/edges (moto/ghost is drawn on each frame)
    @limits  .display(@ctx)
    @entities.display_sprites(@ctx)
    @blocks  .display(@ctx)

    @ctx.restore()

  compute_visibility: ->
    moto = @level.object_to_follow()
    @visible =
      left:   moto.position().x - (@canvas_width  / 2) / @buffer_scale.x
      right:  moto.position().x + (@canvas_width  / 2) / @buffer_scale.x
      bottom: moto.position().y + (@canvas_height / 2) / @buffer_scale.y
      top:    moto.position().y - (@canvas_height / 2) / @buffer_scale.y
    @visible.aabb = new b2AABB()
    @visible.aabb.lowerBound.Set(@visible.left,  @visible.bottom)
    @visible.aabb.upperBound.Set(@visible.right, @visible.top)

  display: ->
    moto = @level.object_to_follow()

    buffer_center_x = @canvas_width / 2
    canvas_center_x = @level.canvas_width / 2
    translate_x     = (moto.position().x - @moto_position.x) * @buffer_scale.x
    clipped_width   = @level.canvas_width  / (@scale.x / @buffer_scale.x)
    margin_zoom_x   = (@level.canvas_width - clipped_width) / 2

    buffer_center_y = @canvas_height / 2
    canvas_center_y = @level.canvas_height / 2
    translate_y     = (moto.position().y - @moto_position.y) * @buffer_scale.y
    clipped_height  = @level.canvas_height / (@scale.y / @buffer_scale.y)
    margin_zoom_y   = (@level.canvas_height - clipped_height) / 2

    @level.ctx.drawImage(
      @canvas,
      buffer_center_x - canvas_center_x  + translate_x + margin_zoom_x, # The x coordinate where to start clipping
      buffer_center_y - canvas_center_y  + translate_y + margin_zoom_y, # The y coordinate where to start clipping
      clipped_width,                                                    # The width of the clipped image
      clipped_height,                                                   # The height of the clipped image
      0,                                                                # The x coordinate where to place the image on the canvas
      0,                                                                # The y coordinate where to place the image on the canvas
      @level.canvas_width,                                              # The width of the image to use (stretch or reduce the image)
      @level.canvas_height)                                             # The height of the image to use (stretch or reduce the image)

