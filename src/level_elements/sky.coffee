class Sky

  constructor: (level) ->
    @level   = level
    @assets  = level.assets
    @theme   = @assets.theme
    @options = level.options

  parse: (xml) ->
    xml_sky  = $(xml).find('level info sky')
    @name    = xml_sky.text().toLowerCase()
    @color_r = parseInt(xml_sky.attr('color_r'))
    @color_g = parseInt(xml_sky.attr('color_g'))
    @color_b = parseInt(xml_sky.attr('color_b'))
    @color_a = parseInt(xml_sky.attr('color_a'))
    @zoom    = parseFloat(xml_sky.attr('zoom'))
    @offset  = parseFloat(xml_sky.attr('offset'))

    @name     = 'sky1' if @name == ''
    @filename = @theme.texture_params(@name).file

    return this

  load_assets: ->
    @assets.textures.push(@filename)

  init: ->
    @init_sprites()

  init_sprites: ->
    texture = PIXI.Texture.from(@assets.get_url(@filename))
    @sprite = new PIXI.TilingSprite(texture, @options.width, @options.height)
    @sprite.position.x = 0
    @sprite.position.y = 0
    @level.stage.addChildAt(@sprite, 0)

  update: ->
    ctx = @level.debug_ctx

    if Constants.debug_physics
      ctx.beginPath()
      ctx.moveTo(@options.width, @options.height)
      ctx.lineTo(0,              @options.height)
      ctx.lineTo(0,              0)
      ctx.lineTo(@options.width, 0)
      ctx.closePath()

      ctx.fillStyle = "#222228"
      ctx.fill()
    # else
    #   @sprite.tileScale.x = 4
    #   @sprite.tileScale.y = 4

    #   position_factor_x = 15
    #   position_factor_y = 7

    #   @sprite.tilePosition.x = -@level.camera.target().x * position_factor_x
    #   @sprite.tilePosition.y =  @level.camera.target().y * position_factor_y
