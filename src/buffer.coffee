b2AABB = Box2D.Collision.b2AABB
b2Vec2 = Box2D.Common.Math.b2Vec2

class Buffer

  constructor: (level) ->
    @level  = level

    # Buffer context
    @canvas = $('#buffer').get(0)
    @ctx    = @canvas.getContext('2d')

    @scale    = @level.scale
    @moto     = @level.moto
    @sky      = @level.sky
    @limits   = @level.limits
    @entities = @level.entities
    @blocks   = @level.blocks

  init_canvas: ->
    @canvas_width  = parseFloat(@canvas.width)
    @canvas_height = parseFloat(@canvas.height)
    @ctx.lineWidth = 0.01

  display: ->
    @init_canvas() if not @canvas_width

    @moto_position =
      x: @moto.position().x
      y: @moto.position().y

    @ctx.clearRect(0, 0, @canvas_width, @canvas_height)
    @ctx.save()

    # initialize position of camera
    @ctx.translate(@canvas_width/2, @canvas_height/2)               # Center of canvas
    @ctx.scale(@scale.x, @scale.y)                                  # Scale (zoom)
    @ctx.translate(-@moto.position().x, -@moto.position().y - 0.25) # Camera on moto

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

    @ctx.restore()
