class Sky

  # XMoto scrolls each sky layer by one texture tile every N seconds, independent of
  # resolution. Keep the 25:15 base:drift ratio to match the original; scale both up
  # together for a gentler wind.
  @SKY_WIND_PERIOD   = 25 # seconds per tile — base sky   (XMoto: fDrift = time / 25)
  @DRIFT_WIND_PERIOD = 15 # seconds per tile — drift layer (XMoto: fDrift = time / 15)

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
    @offset     = @parse_float(xml_sky.attr('offset'),    0.015)
    @drifted    = xml_sky.attr('drifted') == 'true'     # enable the secondary scrolling drift layer
    @blend_name = xml_sky.attr('BlendTexture') || @name # empty => the drift layer reuses the sky texture
    @use_params = xml_sky.attr('use_params') == 'true'  # Not found in C++ code, can be ignored

    if !@has_advanced_options(xml_sky)
      @apply_old_xmoto_values()

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

  # XMoto uses the legacy per-texture presets unless the <sky> element carries at least
  # one advanced attribute (XMoto Level.cpp: v_useAdvancedOptions). use_params is NOT one.
  has_advanced_options: (xml_sky) ->
    attrs = ['zoom', 'offset', 'drifted', 'driftZoom', 'BlendTexture',
             'color_r', 'color_g', 'color_b', 'color_a',
             'driftColor_r', 'driftColor_g', 'driftColor_b', 'driftColor_a']

    for attr in attrs
      return true if xml_sky.attr(attr)?
    false

  # XMoto SkyApparence::setOldXmotoValuesFromTextureName — presets for old-format skies.
  # Unlisted textures keep the reInit defaults (zoom 1.0, offset 0.015, not drifted).
  apply_old_xmoto_values: ->
    switch @name
      when 'sky1'
        @zoom = 2.0
      when 'sky2'
        @zoom = 1.53
      when 'Sky2Drift'
        @zoom        = 1.53
        @drift_zoom  = 1.17
        @drifted     = true
        @color       = { r: 128, g: 128, b: 128, a: 128 }
        @drift_color = { r: 255, g: 128, b: 128, a: 128 }

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

    # XMoto maps 1/zoom tiles across the canvas WIDTH, so the tile scale is tied to the
    # canvas width — this makes the zoom appearance AND the on-screen parallax/wind speed
    # match the original at any window size (a fixed base would bake in one resolution).
    tile_scale          = @zoom * @options.width / @sprite.texture.width
    @sprite.tileScale.x = tile_scale
    @sprite.tileScale.y = tile_scale

    # Add tint to sprite (alpha is ignored in original code; color_a is NOT an opacity —
    # many levels set color_a="0" yet clearly want a visible sky).
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

    tile_scale                = @drift_zoom * @options.width / @drift_sprite.texture.width
    @drift_sprite.tileScale.x = tile_scale
    @drift_sprite.tileScale.y = tile_scale

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

    target   = @level.camera.target()
    tile_px  = @sprite.tileScale.x * @sprite.texture.width # on-screen size of one texture tile
    parallax = @offset * tile_px                           # camera parallax factor (XMoto: camX * offset)

    # Only drifted skies get the constant "wind"; plain skies just track the camera.
    # (XMoto: fDrift stays 0 unless the sky is drifted.) One tile every SKY_WIND_PERIOD
    # seconds, resolution-agnostic and scaling with zoom, like XMoto's fDrift = time / 25.
    wind = 0
    wind = performance.now() / 1000.0 * tile_px / Sky.SKY_WIND_PERIOD if @drifted

    @sprite.tilePosition.x = -target.x * parallax - wind # camera parallax + wind (right → left)
    @sprite.tilePosition.y =  target.y * parallax        # vertical parallax (Y is inverted vs world)

    @update_animation(@sprite) if @sprite.frames_count

  # The drift layer follows the same parallax but slowly scrolls on its own over time.
  update_drifting_sky: ->
    @drift_sprite.width  = @options.width  if @drift_sprite.width  != @options.width
    @drift_sprite.height = @options.height if @drift_sprite.height != @options.height

    target   = @level.camera.target()
    tile_px  = @drift_sprite.tileScale.x * @drift_sprite.texture.width
    parallax = @offset * tile_px                                          # same offset as the base sky
    wind     = performance.now() / 1000.0 * tile_px / Sky.DRIFT_WIND_PERIOD # faster than base (15 vs 25)

    @drift_sprite.tilePosition.x = -target.x * parallax - wind # camera parallax + wind (right → left)
    @drift_sprite.tilePosition.y =  target.y * parallax

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
