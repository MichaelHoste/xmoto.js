class Sounds

  MAX_AUDIBLE_PAN = 6  # After 6 "half-screen" (screen pan goes from -1 to 1), sound is no more audible
  DB_FADE_RANGE   = 60 # dB attenuation from full volume (0dB) down to silence (60dB = 0.001x volume)
  DB_TO_LINEAR    = 20 # standard dB -> linear amplitude divisor

  constructor: (level) ->
    @level  = level
    @assets = level.assets

    @engine = new EngineSound(level)
    @list   = [] # list of loaded sounds

  parse: (xml) ->
    # Sounds available to all levels
    sound_names = ['EndOfLevel', 'Headcrash']

    # Only when strawberries (or equivalent) in the level
    if $(xml).find('entity[typeid="Strawberry"]').length
      sound_names.push('PickUpStrawberry')

    # Only when checkpoint in the level
    if $(xml).find('entity[typeid="Checkpoint"]').length
      sound_names.push('Checkpoint')

    for sound_name in sound_names
      # theme_replacements in level XML
      if @level.replacements.sprites[name]
        sound_name = @level.replacements.sprites[name]

      # get infos (file) from theme
      theme_sound = @assets.theme.sound_params(sound_name)

      @list.push(theme_sound)

  load_assets: ->
    for sound in @list
      @assets.sounds.push(sound.file)

  init: ->
    @engine.init()

  update: ->
    @update_engine()

  # Drives the procedural motor with the live rear-wheel speed and throttle (the "up" key).
  update_engine: ->
    moto        = @level.moto
    rpm         = Math.abs(moto.left_wheel.getAngularVelocity())
    rpm_norm    = Math.min(1, rpm / Constants.max_moto_speed)
    throttle    = if moto.dead then 0 else (if @level.input.up then 1 else 0)

    @engine.update(rpm_norm, throttle)

  # Relative "pan" value for the position relative to the screen
  #         -----------
  #         |         |
  #         |         |
  #         -----------
  #  <1    -1 ....... 1    >=1
  audio_pan: (position) ->
    camera = @level.camera
    center = camera.target().x
    half_w = @level.options.width / 2

    (position.x - center) * camera.scale.x / half_w

  clamp: (value, min, max) ->
      Math.max(min, Math.min(max, value))

  db_to_linear: (db) ->
    Math.pow(10, -db / DB_TO_LINEAR)

  stereo_filter: (position) ->
    pan = @audio_pan(position)
    pan = @clamp(pan, -1, 1) # force in [-1...1] => 100% left on left screen border and above
                             #                   => 100% right on right screen border and above

    new PIXI.sound.filters.StereoFilter(pan)

  volume: (position) ->
    pan = @audio_pan(position)

    distance_past_screen = Math.max(0, Math.abs(pan) - 1) # Sounds on the screen (|pan| <= 1) get no attenuation.
    fade_zone_width      = MAX_AUDIBLE_PAN - 1            # Attenuation distance outside the screen

    return 0 if distance_past_screen >= fade_zone_width # too far, not audible

    fade_fraction = distance_past_screen / fade_zone_width
    fade_fraction = @clamp(fade_fraction, 0, 1) # force in [0...1]

    @db_to_linear(fade_fraction * DB_FADE_RANGE)

  @play: (name, options) ->
    no_volume = options.volume? && options.volume == 0

    PIXI.sound.play(name, options) unless no_volume
