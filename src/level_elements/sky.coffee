class Sky

  # Visual tuning constants (reverse-engineered to look nice)
  @PARALLAX_X       = 15 # sky parallax on the x axis
  @PARALLAX_Y       = 7  # sky parallax on the y axis
  # XMoto scrolls each sky layer by one texture tile every N seconds, independent of
  # resolution. Keep the 25:15 base:drift ratio to match the original; scale both up
  # together for a gentler wind.
  @SKY_WIND_PERIOD   = 25 # seconds per tile — base sky   (XMoto: fDrift = time / 25)
  @DRIFT_WIND_PERIOD = 15 # seconds per tile — drift layer (XMoto: fDrift = time / 15)
  @TILE_SCALE_BASE  = 4  # tile scale at zoom 1.0 (historical value); zoom multiplies it

  constructor: (level) ->
    @level   = level
    @assets  = level.assets
    @options = level.options

  parse: (xml) ->
    xml_sky = $(xml).find('level info sky')

    @name = xml_sky.text() || 'sky1'

    @color =
      r: @parse_color(xml_sky, 'color_r')
      g: @parse_color(xml_sky, 'color_g')
      b: @parse_color(xml_sky, 'color_b')
      a: @parse_color(xml_sky, 'color_a')

    @drift_color =
      r: @parse_color(xml_sky, 'driftColor_r')
      g: @parse_color(xml_sky, 'driftColor_g')
      b: @parse_color(xml_sky, 'driftColor_b')
      a: @parse_color(xml_sky, 'driftColor_a')

    @zoom       = @parse_float(xml_sky.attr('zoom'),      1.0)
    @drift_zoom = @parse_float(xml_sky.attr('driftZoom'), 1.0)
    @offset     = @parse_float(xml_sky.attr('offset'),    0.0)
    @drifted    = xml_sky.attr('drifted')    == 'true'  # enable the secondary scrolling drift layer
    @blend_name = xml_sky.attr('BlendTexture') || @name # empty => the drift layer reuses the sky texture
    @use_params = xml_sky.attr('use_params') == 'true'  # Not found in C++ code, can be ignored

    # Get texture filenames from theme (can be animated!)
    # => For sky
    sky_params = @assets.theme.texture_params(@name)

    if sky_params.frames_count
      @sky_frames_count = sky_params.frames_count
      @sky_delay        = sky_params.delay
      @sky_filenames    = @texture_names(sky_params)
    else
      @sky_filenames = [sky_params.file]

    # => For drifted sky
    drifted_sky_params = @assets.theme.texture_params(@blend_name)

    if drifted_sky_params.frames_count
      @drifted_sky_frames_count = drifted_sky_params.frames_count
      @drifted_sky_delay        = drifted_sky_params.delay
      @drifted_sky_filenames    = @texture_names(drifted_sky_params)
    else
      @drifted_sky_filenames = [drifted_sky_params.file]

    return this

  load_assets: ->
    # static/animated files for both skies
    for sky_filename in @sky_filenames.concat(@drifted_sky_filenames)
      @assets.textures.push(sky_filename)

  init: ->
    @init_graphics()

  init_graphics: ->
    @init_sky()
    @init_drifting_sky() if @drifted

  init_sky: ->
    textures = (PIXI.Texture.from(@assets.get_url(name)) for name in @sky_filenames)
    @sprite  = new PIXI.TilingSprite({ texture: textures[0], width: @options.width, height: @options.height })

    if @sky_frames_count
      @sprite.textures        = textures
      @sprite.frames_count    = @sky_frames_count
      @sprite.delay           = @sky_delay
      @sprite.current_frame   = 0
      @sprite.animation_start = performance.now()

    @sprite.label = "sky"

    @sprite.position.x = 0
    @sprite.position.y = 0

    # color / zoom apply whenever present (defaults white + zoom 1.0 => historical look).
    # Only the RGB tints the sky: the base sky is opaque, so color_a is NOT an opacity
    # (many levels set color_a="0" yet clearly want a visible sky).
    @sprite.tileScale.x = @zoom * Sky.TILE_SCALE_BASE
    @sprite.tileScale.y = @zoom * Sky.TILE_SCALE_BASE

    # Add tint to sprite (alpha is ignored in original code)
    @sprite.tint = (@color.r << 16) + (@color.g << 8) + @color.b

    @level.stage.addChildAt(@sprite, 0) # Fixed on the root level of stage (not influenced by scale/translation, only adapt tilePosition)

  # Second tiling texture drifting over the sky (moving clouds / atmosphere).
  init_drifting_sky: ->
    textures      = (PIXI.Texture.from(@assets.get_url(name)) for name in @drifted_sky_filenames)
    @drift_sprite = new PIXI.TilingSprite({ texture: textures[0], width: @options.width, height: @options.height })

    if @drifted_sky_frames_count
      @drift_sprite.textures        = textures
      @drift_sprite.frames_count    = @drifted_sky_frames_count
      @drift_sprite.delay           = @drifted_sky_delay
      @drift_sprite.current_frame   = 0
      @drift_sprite.animation_start = performance.now()

    @drift_sprite.label = "sky drift"

    @drift_sprite.position.x = 0
    @drift_sprite.position.y = 0

    @drift_sprite.tileScale.x = @drift_zoom * Sky.TILE_SCALE_BASE
    @drift_sprite.tileScale.y = @drift_zoom * Sky.TILE_SCALE_BASE

    # Add tint to sprite (alpha is ignored in original code)
    @drift_sprite.tint = (@drift_color.r << 16) + (@drift_color.g << 8) + @drift_color.b

    # Additive so the drift combines with the sky instead of hiding it (matches XMoto,
    # and explains the very dark driftColors seen in some levels). Switch to 'normal' to compare.
    @drift_sprite.blendMode = 'add'

    @level.stage.addChildAt(@drift_sprite, 1) # Just above the sky, below the game world

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
      @update_sky()
      @update_drifting_sky() if @drifted

  update_sky: ->
    # Only when going in/out fullscreen (avoid some internal computations)
    @sprite.width  = @options.width  if @sprite.width  != @options.width
    @sprite.height = @options.height if @sprite.height != @options.height

    target = @level.camera.target()
    # Only drifted skies get the constant "wind"; plain skies just track the camera.
    # (XMoto: fDrift stays 0 unless the sky is drifted.) Scroll one tile every
    # SKY_WIND_PERIOD seconds, sized from the on-screen tile (tileScale × texture width)
    # so it is resolution-agnostic and scales with zoom, like XMoto's fDrift = time / 25.
    wind = 0
    if @drifted
      tile_px = @sprite.tileScale.x * @sprite.texture.width
      wind    = performance.now() / 1000.0 * tile_px / Sky.SKY_WIND_PERIOD

    @sprite.tilePosition.x = -target.x * Sky.PARALLAX_X - wind # -wind => scrolls right → left
    @sprite.tilePosition.y =  target.y * Sky.PARALLAX_Y + @offset * @options.height # offset shifts the sky vertically

    @update_animation(@sprite) if @sprite.frames_count

  # The drift layer follows the same parallax but slowly scrolls on its own over time.
  update_drifting_sky: ->
    @drift_sprite.width  = @options.width  if @drift_sprite.width  != @options.width
    @drift_sprite.height = @options.height if @drift_sprite.height != @options.height

    target  = @level.camera.target()
    tile_px = @drift_sprite.tileScale.x * @drift_sprite.texture.width
    wind    = performance.now() / 1000.0 * tile_px / Sky.DRIFT_WIND_PERIOD # faster than base (15 vs 25)

    @drift_sprite.tilePosition.x = -target.x * Sky.PARALLAX_X - wind # -wind => scrolls right → left
    @drift_sprite.tilePosition.y =  target.y * Sky.PARALLAX_Y

    @update_animation(@drift_sprite) if @drift_sprite.frames_count

  # Swap an animated sky layer to its current time-based frame (see init_sky). The
  # animation state (textures/frames_count/delay/current_frame/animation_start) lives
  # on the sprite, mirroring how animated Blocks store it on the block.
  update_animation: (sprite) ->
    elapsed = (performance.now() - sprite.animation_start) / 1000.0
    frame   = Math.floor(elapsed / sprite.delay) % sprite.frames_count

    if frame != sprite.current_frame
      sprite.current_frame = frame
      sprite.texture       = sprite.textures[frame]

  texture_names: (texture_params) ->
    for frame_i in [0..texture_params.frames_count - 1]
      "#{texture_params.file_base}#{(frame_i/100.0).toFixed(2).toString().substring(2)}.#{texture_params.file_extension}"

  parse_color: (xml_sky, name) ->
    value = $(xml_sky).attr(name)
    if value? then parseInt(value) else 255 # to manage that if NaN => 255, but if 0 => 0

  parse_float: (value, fallback) ->
    if value? then parseFloat(value) else fallback
