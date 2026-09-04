class Sounds

  MAX_AUDIBLE_PAN = 6  # After 6 "half-screen" (screen pan goes from -1 to 1), sound is no more audible
  DB_FADE_RANGE   = 60 # dB attenuation from full volume (0dB) down to silence (60dB = 0.001x volume)
  DB_TO_LINEAR    = 20 # standard dB -> linear amplitude divisor

  constructor: (level) ->
    @level  = level
    @assets = level.assets

    @list   = []

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
    @engine = new EngineSound(@level)
    @engine.init()

  update: ->
    @engine.update() if @engine

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

# Procedural engine sound built directly on the Web Audio API (same AudioContext
# as pixi-sound). No samples: a stack of oscillators (fundamental + detuned 2nd
# harmonic + sub), soft-clip distortion and band-passed noise, all driven by:
#   - pitch: rear wheel rotation speed (0..1 of Constants.max_moto_speed)
#   - load:  throttle (up key) -> volume, brightness (lowpass), distortion, noise
# Coasting at max wheel speed stays a quiet engine-brake sound, never full throttle.
#
# NOTE: defined in this file (not its own .coffee file) because the watcher's
# file list is fixed at launch: a new file wouldn't be compiled into bin/xmoto.js.
class EngineSound

  @current = null # only one engine can play (levels are never explicitly destroyed)

  PITCH_RISE_TAU = 0.20 # seconds to rev up   (~63% of the way per tau)
  PITCH_FALL_TAU = 0.45 # seconds to rev down
  LOAD_RISE_TAU  = 0.06 # throttle attack
  LOAD_FALL_TAU  = 0.30 # throttle release

  constructor: (level) ->
    @level = level
    @pitch = 0.0 # smoothed rpm fraction [0..1]
    @load  = 0.0 # smoothed throttle     [0..1]

  init: ->
    return unless @level.options.playable && Constants.engine_sound.enabled

    EngineSound.current.destroy() if EngineSound.current
    EngineSound.current = this

    @ctx = PIXI.sound.context.audioContext
    now  = @ctx.currentTime
    c    = Constants.engine_sound

    # master gain -> speakers (starts silent, faded in by update())
    @master = @ctx.createGain()
    @master.gain.value = 0.0
    @master.connect(@ctx.destination)

    # lowpass -> master (cutoff tracks pitch and load: closed = muffled coasting)
    @lowpass                 = @ctx.createBiquadFilter()
    @lowpass.type            = 'lowpass'
    @lowpass.frequency.value = c.lowpass_base
    @lowpass.Q.value         = 2.0
    @lowpass.connect(@master)

    # soft-clip waveshaper -> lowpass (exhaust growl, driven harder under load)
    @shaper            = @ctx.createWaveShaper()
    @shaper.curve      = @distortion_curve()
    @shaper.oversample = '2x'
    @shaper.connect(@lowpass)

    # drive gain -> shaper (more input gain = more distortion)
    @drive            = @ctx.createGain()
    @drive.gain.value = 1.0
    @drive.connect(@shaper)

    # oscillator stack -> drive
    @osc1 = @create_oscillator('sawtooth', c.min_frequency,       0.50) # fundamental
    @osc2 = @create_oscillator('sawtooth', c.min_frequency * 2.0, 0.22) # 2nd harmonic (detuned)
    @sub  = @create_oscillator('square',   c.min_frequency / 2.0, 0.35) # sub thump

    # white noise -> bandpass -> gain -> drive (mechanical/exhaust texture)
    @noise                        = @ctx.createBufferSource()
    @noise.buffer                 = @create_noise_buffer()
    @noise.loop                   = true
    @noise_filter                 = @ctx.createBiquadFilter()
    @noise_filter.type            = 'bandpass'
    @noise_filter.frequency.value = 400 + c.min_frequency * 6
    @noise_filter.Q.value         = 0.7
    @noise_gain                   = @ctx.createGain()
    @noise_gain.gain.value        = c.noise_idle
    @noise.connect(@noise_filter)
    @noise_filter.connect(@noise_gain)
    @noise_gain.connect(@drive)

    osc.start(now) for osc in [@osc1, @osc2, @sub, @noise]

    @bind_audio_unlock()
    @bind_visibility()

  create_oscillator: (type, frequency, volume) ->
    osc                 = @ctx.createOscillator()
    osc.type            = type
    osc.frequency.value = frequency

    gain            = @ctx.createGain()
    gain.gain.value = volume

    osc.connect(gain)
    gain.connect(@drive)

    osc

  create_noise_buffer: ->
    buffer = @ctx.createBuffer(1, @ctx.sampleRate, @ctx.sampleRate) # 1 second
    data   = buffer.getChannelData(0)
    for i in [0...data.length]
      data[i] = Math.random() * 2.0 - 1.0
    buffer

  distortion_curve: (amount = 2.5, samples = 1024) ->
    curve = new Float32Array(samples)
    for i in [0...samples]
      x        = (i * 2.0) / (samples - 1) - 1.0
      curve[i] = Math.tanh(amount * x)
    curve

  # Browsers create the AudioContext "suspended" until a user gesture
  bind_audio_unlock: ->
    $(document).on 'keydown.engine_sound pointerdown.engine_sound touchstart.engine_sound', =>
      if @ctx && @ctx.state == 'suspended'
        @ctx.resume()
      else
        $(document).off('.engine_sound')

  # The game loop stops when the tab is hidden: cut the engine so it doesn't drone
  bind_visibility: ->
    @on_visibility = =>
      if document.hidden && @ctx # update() restores the volume when back
        @master.gain.cancelScheduledValues(@ctx.currentTime)
        @master.gain.setTargetAtTime(0.0, @ctx.currentTime, 0.02)
    document.addEventListener('visibilitychange', @on_visibility)

  update: ->
    return unless @ctx

    now = @ctx.currentTime
    dt  = if @last_time? then Math.min(now - @last_time, 0.1) else 1.0 / 60.0
    @last_time = now

    c        = Constants.engine_sound
    moto     = @level.moto
    input    = @level.input
    throttle = if input.up && !moto.dead then 1.0 else 0.0

    # rear wheel rotation speed as rpm proxy (rear = left_wheel, the driven one)
    wheel_fraction = Math.abs(moto.left_wheel.getAngularVelocity()) / Constants.max_moto_speed
    wheel_fraction = Math.min(wheel_fraction, 1.0)

    target_pitch = Math.min(wheel_fraction + throttle * c.throttle_rev_bonus, 1.0)
    target_pitch = Math.min(target_pitch, c.coast_max_pitch) if throttle == 0.0

    @pitch = @approach(@pitch, target_pitch, dt, if target_pitch > @pitch then PITCH_RISE_TAU else PITCH_FALL_TAU)
    @load  = @approach(@load,  throttle,     dt, if throttle > @load then LOAD_RISE_TAU else LOAD_FALL_TAU)

    f0     = c.min_frequency + Math.pow(@pitch, c.pitch_curve) * (c.max_frequency - c.min_frequency)
    wobble = (Math.random() - 0.5) * 2.0 * c.idle_wobble * (1.0 - @pitch) # lumpy idle

    @osc1.frequency.setTargetAtTime(f0,       now, 0.03)
    @osc2.frequency.setTargetAtTime(f0 * 2.0, now, 0.03)
    @sub.frequency.setTargetAtTime( f0 / 2.0, now, 0.03)
    @osc1.detune.setTargetAtTime(wobble,       now, 0.05)
    @osc2.detune.setTargetAtTime(wobble + 8.0, now, 0.05) # constant +8 cents = richer tone

    @lowpass.frequency.setTargetAtTime(c.lowpass_base + @pitch * c.lowpass_pitch + @load * c.lowpass_load, now, 0.05)
    @noise_filter.frequency.setTargetAtTime(400 + f0 * 6.0, now, 0.05)
    @noise_gain.gain.setTargetAtTime(c.noise_idle + @load * c.noise_load + @pitch * 0.08, now, 0.05)
    @drive.gain.setTargetAtTime(1.0 + @load * c.drive_load, now, 0.05)

    if moto.dead || !c.enabled
      @master.gain.setTargetAtTime(0.0, now, 0.08) # cut the engine on death
    else
      volume = c.volume * (0.28 + 0.22 * @pitch + 0.50 * @load)
      @master.gain.setTargetAtTime(volume, now, 0.05)

  approach: (current, target, dt, tau) ->
    current + (target - current) * (1.0 - Math.exp(-dt / tau))

  destroy: ->
    if @ctx
      try
        osc.stop() for osc in [@osc1, @osc2, @sub, @noise]
      catch error
        ; # already stopped
      @master.disconnect()
      $(document).off('.engine_sound')
      document.removeEventListener('visibilitychange', @on_visibility)
      @ctx = null

    EngineSound.current = null if EngineSound.current == this
