class Sky

  constructor: (level) ->
    @level  = level
    @assets = level.assets
    @theme  = @assets.theme

  parse: (xml) ->
    xml_sky    = $(xml).find('level info sky')
    @name      = xml_sky.text().toLowerCase()
    @color_r   = parseInt(xml_sky.attr('color_r'))
    @color_g   = parseInt(xml_sky.attr('color_g'))
    @color_b   = parseInt(xml_sky.attr('color_b'))
    @color_a   = parseInt(xml_sky.attr('color_a'))
    @zoom      = parseFloat(xml_sky.attr('zoom'))
    @offset    = parseFloat(xml_sky.attr('offset'))

    @name      = 'sky1' if @name == ''
    @file_name = @theme.texture_params(@name).file

    return this

  load_assets: ->
    @assets.textures.push(@file_name)

  init: ->
    @init_sprites()

  init_sprites: ->
    texture = PIXI.Texture.fromImage(@assets.get_url(@file_name))
    @sprite = new PIXI.extras.TilingSprite(texture, @level.canvas_width, @level.canvas_height)
    @sprite.position.x = 0
    @sprite.position.y = 0
    @level.stage.addChildAt(@sprite, 0)

  display: ->
    ctx = @level.ctx

    ctx.beginPath()
    ctx.moveTo(@level.canvas_width, @level.canvas_height)
    ctx.lineTo(0,                   @level.canvas_height)
    ctx.lineTo(0,                   0)
    ctx.lineTo(@level.canvas_width, 0)
    ctx.closePath()

    if Constants.debug
      ctx.fillStyle = "#222228"
      ctx.fill()
    else
      ctx.save()
      ctx.scale(4.0, 4.0)
      ctx.translate(-@level.camera.target().x*4, @level.camera.target().y*2)
      ctx.fillStyle = ctx.createPattern(@assets.get(@file_name), "repeat")
      ctx.fill()
      ctx.restore()

    @sprite.tileScale.x = 4
    @sprite.tileScale.y = 4

    position_factor_x = 15
    position_factor_y = 7

    # TODO: REMOVE THIS WHEN UPGRADING VERSION (https://github.com/pixijs/pixi.js/pull/2028)
    if @level.renderer.type == PIXI.RENDERER_TYPE.CANVAS
      position_factor_x /= @sprite.tileScale.x
      position_factor_y /= @sprite.tileScale.y

    @sprite.tilePosition.x = -@level.camera.target().x * position_factor_x
    @sprite.tilePosition.y =  @level.camera.target().y * position_factor_y
