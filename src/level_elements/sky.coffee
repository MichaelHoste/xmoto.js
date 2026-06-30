class Sky

  constructor: (level) ->
    @level   = level
    @assets  = level.assets
    @options = level.options

  parse: (xml) ->
    xml_sky  = $(xml).find('level info sky')
    @name    = xml_sky.text()
    @color_r = parseInt(xml_sky.attr('color_r'))
    @color_g = parseInt(xml_sky.attr('color_g'))
    @color_b = parseInt(xml_sky.attr('color_b'))
    @color_a = parseInt(xml_sky.attr('color_a'))
    @zoom    = parseFloat(xml_sky.attr('zoom'))
    @offset  = parseFloat(xml_sky.attr('offset'))

    @name     = 'sky1' if @name == ''
    @filename = @assets.theme.texture_params(@name).file

    return this

  load_assets: ->
    @assets.textures.push(@filename)

  init: ->
    @init_graphics()

  init_graphics: ->
    texture = PIXI.Texture.from(@assets.get_url(@filename))
    @sprite = new PIXI.TilingSprite({ texture: texture, width: @options.width, height: @options.height })

    @sprite.label = "sky"

    @sprite.position.x = 0
    @sprite.position.y = 0

    @sprite.tileScale.x = 4
    @sprite.tileScale.y = 4

    @level.stage.addChildAt(@sprite, 0) # Fixed on the root level of stage (not influenced by scale/translation, only adapt tilePosition)

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
    else
      # Only when going in/out fullscreen (avoid some internal computations)
      @sprite.width  = @options.width  if @sprite.width  != @options.width
      @sprite.height = @options.height if @sprite.height != @options.height

      parallax_x = 15 # sky parallax on x axix
      parallax_y = 7  # sky parallax on y axis

      @sprite.tilePosition.x = -@level.camera.target().x * parallax_x
      @sprite.tilePosition.y =  @level.camera.target().y * parallax_y
