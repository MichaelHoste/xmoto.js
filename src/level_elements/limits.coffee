b2Vec2 = b2.Vec2
b2AABB = b2.AABB

class Limits

  constructor: (level) ->
    @level  = level
    @assets = level.assets
    @theme  = @assets.theme

  parse: (xml) ->
    xml_limits = $(xml).find('limits')

    # CAREFUL ! The limits on files are not real, some polygons could
    # be in the limits (maybe it's the limits where the player can go)

    @player =
      left:   parseFloat(xml_limits.attr('left'))
      right:  parseFloat(xml_limits.attr('right'))
      top:    parseFloat(xml_limits.attr('top'))
      bottom: parseFloat(xml_limits.attr('bottom'))

    @screen =
      left:   parseFloat(xml_limits.attr('left'))   - 20
      right:  parseFloat(xml_limits.attr('right'))  + 20
      top:    parseFloat(xml_limits.attr('top'))    + 20
      bottom: parseFloat(xml_limits.attr('bottom')) - 20

    @size =
      x: @screen.right - @screen.left
      y: @screen.top   - @screen.bottom

    @texture = 'dirt'
    @texture_name = @theme.texture_params('dirt').file

    return this

  init: ->
    # Assets
    @assets.textures.push(@texture_name)

    # Collisions with borders

    ground = Constants.ground

    # Left
    vertices = []
    vertices.push({ x: @screen.left, y: @screen.top })
    vertices.push({ x: @screen.left, y: @screen.bottom })
    vertices.push({ x: @player.left, y: @screen.bottom })
    vertices.push({ x: @player.left, y: @screen.top })
    @level.physics.create_polygon(vertices, 'ground', ground.density, ground.restitution, ground.friction)

    # Right
    vertices = []
    vertices.push({ x: @player.right, y: @screen.top })
    vertices.push({ x: @player.right, y: @screen.bottom })
    vertices.push({ x: @screen.right, y: @screen.bottom })
    vertices.push({ x: @screen.right, y: @screen.top })
    @level.physics.create_polygon(vertices, 'ground', ground.density, ground.restitution, ground.friction)

    # Bottom
    vertices = []
    vertices.push({ x: @player.right, y: @player.bottom })
    vertices.push({ x: @player.left,  y: @player.bottom })
    vertices.push({ x: @player.left,  y: @screen.bottom })
    vertices.push({ x: @player.right, y: @screen.bottom })
    @level.physics.create_polygon(vertices, 'ground', ground.density, ground.restitution, ground.friction)

    # Bottom
    vertices = []
    vertices.push({ x: @player.right, y: @screen.top })
    vertices.push({ x: @player.left,  y: @screen.top })
    vertices.push({ x: @player.left,  y: @player.top })
    vertices.push({ x: @player.right, y: @player.top })

    @level.physics.create_polygon(vertices, 'ground', ground.density, ground.restitution, ground.friction)

  display: (ctx) ->
    return false if Constants.debug

    buffer = @level.buffer

    # Left border
    if @player.left > buffer.visible.left
      ctx.beginPath()
      ctx.moveTo(@screen.left, @screen.top   )
      ctx.lineTo(@screen.left, @screen.bottom)
      ctx.lineTo(@player.left, @screen.bottom)
      ctx.lineTo(@player.left, @screen.top   )
      ctx.closePath()
      @save_apply_texture_and_restore(ctx)

    # Right border
    if @player.right < buffer.visible.right
      ctx.beginPath()
      ctx.moveTo(@screen.right, @screen.top   )
      ctx.lineTo(@screen.right, @screen.bottom)
      ctx.lineTo(@player.right, @screen.bottom)
      ctx.lineTo(@player.right, @screen.top   )
      ctx.closePath()
      @save_apply_texture_and_restore(ctx)

    # Bottom border
    if @player.bottom > buffer.visible.bottom
      ctx.beginPath()
      ctx.moveTo(@player.right, @player.bottom)
      ctx.lineTo(@player.left,  @player.bottom)
      ctx.lineTo(@player.left,  @screen.bottom)
      ctx.lineTo(@player.right, @screen.bottom)
      ctx.closePath()
      @save_apply_texture_and_restore(ctx)

    # Top border
    if @player.top < buffer.visible.top
      ctx.beginPath()
      ctx.moveTo(@player.right, @screen.top)
      ctx.lineTo(@player.left,  @screen.top)
      ctx.lineTo(@player.left,  @player.top)
      ctx.lineTo(@player.right, @player.top)
      ctx.closePath()
      @save_apply_texture_and_restore(ctx)

  save_apply_texture_and_restore: (ctx) ->
    ctx.save()
    ctx.scale(1.0 / 40.0, -1.0 / 40.0)
    ctx.fillStyle = ctx.createPattern(@assets.get(@texture_name), "repeat")
    ctx.fill()
    ctx.restore()

