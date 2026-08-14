class EngineSound

  # Procedurally-synthesized motorcycle engine (layered Web Audio voices).
  #
  #   Wheel RPM  -> pitch/frequency of the tone (idle .. redline)
  #   Throttle   -> loudness, harmonic richness, exhaust texture ("load")
  #
  # The "up" key is the throttle: wheel speed alone never produces a
  # full-throttle character. When coasting (no throttle) at high RPM the tone
  # is still high-pitched, but stays quiet and lean.
  #
  # Built lazily and resumed after the first user gesture (autoplay-safe).

  constructor: (level) ->
    @level    = level
    @ctx      = null
    @running  = false

    @rpm      = 0 # smoothed 0..1
    @throttle = 0 # smoothed 0..1

  idle_hz:     30  # fundamental at standstill (deep)
  range_hz:   130  # fundamental sweep to redline (~160 Hz)
  coast_vol: 0.13  # idle floor: audible engine ticking while rolling/stopped
  throttle_vol: 0.55 # volume under full throttle

  # A single shared AudioContext across every level/game, so we don't leak a
  # context per `.xmoto()` load (Level has no destroy path).
  audio_context: ->
    window.__xmoto_audio_ctx ?= new (window.AudioContext || window.webkitAudioContext)()

  init: ->
    @ctx = @audio_context()
    @build_graph()

    # Autoplay policy: unlock once after the first user gesture.
    unlock = =>
      @ctx.resume() if @ctx.state == 'suspended'
    document.addEventListener('keydown',   unlock, { once: true })
    document.addEventListener('pointerdown', unlock, { once: true })

  build_graph: ->
    ctx = @ctx

    # Dynamics safety net: keeps the summed voices from hard-clipping.
    @compressor = ctx.createDynamicsCompressor()
    @compressor.connect(ctx.destination)

    @master = ctx.createGain()
    @master.gain.value = 0
    @master.connect(@compressor)

    # Whole voice stack passes through one lowpass, so we can sweep the tone's
    # brightness with a single cutoff instead of many per-voice filters.
    @lowpass = ctx.createBiquadFilter()
    @lowpass.type = 'lowpass'
    @lowpass.frequency.value = 500
    @lowpass.Q.value = 0.7
    @lowpass.connect(@master)

    voices = [
      { type: 'sine',     ratio: 0.5, gain: 0.32 } # sub "thump" (half the fundamental)
      { type: 'sawtooth', ratio: 1.0, gain: 0.50 } # fundamental
      { type: 'square',   ratio: 2.0, gain: 0.20 } # 2nd harmonic
      { type: 'sawtooth', ratio: 3.0, gain: 0.13 } # 3rd harmonic
      { type: 'sawtooth', ratio: 4.0, gain: 0.08 } # 4th harmonic
    ]

    @voices = []
    for v in voices
      osc = ctx.createOscillator()
      osc.type = v.type
      osc.frequency.value = @idle_hz * v.ratio
      osc.start()

      gain = ctx.createGain()
      gain.gain.value = v.gain
      osc.connect(gain)
      gain.connect(@lowpass)

      # Each voice gets its own tiny detune/beat/phase so the stack produces
      # beating, chuggy irregularities instead of a sterile harmonic sine.
      @voices.push({
        ratio:     v.ratio
        base_gain: v.gain
        osc:       osc
        gain:      gain
        detune:    0.002 + Math.random() * 0.006
        beat:      5 + Math.random() * 11
        phase:     Math.random() * Math.PI * 2
      })

    # Exhaust / mechanical texture: looped white noise through a bandpass.
    # Only audible while throttling, so idling stays clean.
    @noise_filter = ctx.createBiquadFilter()
    @noise_filter.type = 'bandpass'
    @noise_filter.frequency.value = 900
    @noise_filter.Q.value = 0.8

    @noise_gain = ctx.createGain()
    @noise_gain.gain.value = 0
    @noise_filter.connect(@noise_gain)
    @noise_gain.connect(@master)

    noise = ctx.createBufferSource()
    noise.buffer = @make_noise_buffer()
    noise.loop = true
    noise.start()
    noise.connect(@noise_filter)

  make_noise_buffer: ->
    ctx  = @ctx
    len  = Math.floor(ctx.sampleRate)
    buf  = ctx.createBuffer(1, len, ctx.sampleRate)
    data = buf.getChannelData(0)
    for i in [0...len]
      data[i] = Math.random() * 2 - 1
    buf

  # Called every frame (from Sounds.update) with live inputs.
  update: (rpm01, throttle01) ->
    ctx = @ctx

    unless @running
      return if ctx.state == 'suspended' # still waiting for a user gesture
      @running = true

    # One-pole smoothing of the jittery per-frame inputs
    @rpm      += (rpm01 - @rpm) * 0.14
    @throttle += (throttle01 - @throttle) * 0.20

    rpm = @rpm
    thr = @throttle
    now = ctx.currentTime

    TWO_PI = 2 * Math.PI

    # Compress wheel speed so the engine stays deep until real revs build up,
    # instead of ramping to a high whine early.
    rpm_eff = Math.pow(rpm, 1.3)

    # Pitch follows wheel speed, but relaxing the throttle pulls the note back
    # down toward idle (like easing off). Full pitch needs throttle too.
    effort  = 0.45 + 0.55 * thr
    freq    = @idle_hz + @range_hz * rpm_eff * effort

    idle = 1 - rpm_eff

    # Rough-idle wobble: uneven firing / lag at low RPM, evens out higher up
    wobble = idle * (0.006 * Math.sin(now * TWO_PI * 7.3) +
                     0.004 * Math.sin(now * TWO_PI * 13.1 + 1))
    # Slow "chug" from the firing cadence, mostly at idle
    chug   = idle * 0.03 * (0.5 + 0.5 * Math.sin(now * TWO_PI * 2.2))
    # Load rumble under throttle (felt through the frame)
    rumble = thr * 0.015 * Math.sin(now * TWO_PI * 31)

    for voice in @voices
      # Per-voice detune creates beating roughness, strongest at idle
      detune = 1 + voice.detune * (0.35 + idle * 0.55) *
                Math.sin(now * TWO_PI * voice.beat + voice.phase)
      voice.osc.frequency.setTargetAtTime(freq * voice.ratio * detune, now, 0.02)

      # Harmonics fatten up under load (throttle), lean while coasting
      g = voice.base_gain * (1 + thr * (voice.ratio - 0.5) * 0.30) *
          (1 + wobble * voice.ratio * 0.5)
      voice.gain.gain.setTargetAtTime(g, now, 0.02)

    # Brightness is gated by throttle: muffled + low on lift-off, opens up
    # under load. This keeps high speed from sounding shrill while coasting.
    brightness = 0.4 + 0.6 * thr
    @lowpass.frequency.setTargetAtTime(
      100 + (rpm_eff * 700 + thr * 200) * brightness, now, 0.03)

    # Mechanical/exhaust texture: a little always (so it's not sterile),
    # much more under load
    @noise_gain.gain.setTargetAtTime(0.03 + thr * 0.09 + idle * 0.02, now, 0.03)
    @noise_filter.frequency.setTargetAtTime(300 + rpm_eff * 900, now, 0.03)

    # Master: quiet idle floor + throttle-driven load, with chug/rumble motion
    volume  = @coast_vol + thr * (@throttle_vol - @coast_vol)
    volume += chug + rumble
    volume *= (1 + wobble * 0.6)
    volume  = 0 if @level.moto.dead # engine cuts on crash
    @master.gain.setTargetAtTime(volume, now, 0.03)
