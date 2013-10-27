class EngineSound

  constructor: (level) ->
    @level  = level
    @assets = level.assets
    @engine = []
    @loaded = false

  load: ->
    if not @loaded
      @engine.push(createjs.Sound.createInstance('engine_0000'))
      @engine.push(createjs.Sound.createInstance('engine_1000'))
      @engine.push(createjs.Sound.createInstance('engine_2000'))
      @engine.push(createjs.Sound.createInstance('engine_3000'))
      @engine.push(createjs.Sound.createInstance('engine_4000'))
      @engine.push(createjs.Sound.createInstance('engine_5000'))
      @engine.push(createjs.Sound.createInstance('engine_6000'))
      @old_vitesse = 1
      @loaded = true

  play: ->
    @load() if not @loaded

    velocity = @level.moto.left_wheel.GetAngularVelocity()
    vitesse  = Math.round(Math.abs(velocity/10))
    vitesse  = 6 if vitesse > 6

    console.log(vitesse)

    if vitesse != @old_vitesse
      @engine[@old_vitesse].pause()
      @engine[vitesse].play({loop: -1})

    @old_vitesse = vitesse
