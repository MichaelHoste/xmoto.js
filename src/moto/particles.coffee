class Particles

  constructor: (level, replay) ->
    @level   = level
    @physics = level.physics
    @world   = @physics.world
    @list    = []

  create: ->
    # Create fixture
    fixDef = new b2FixtureDef()

    fixDef.shape       = new b2CircleShape(0.04)
    fixDef.density     = 1.0
    fixDef.restitution = 0.5
    fixDef.friction    = 1.0
    fixDef.isSensor    = false
    fixDef.filter.groupIndex = -1

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = @level.moto.left_wheel.GetPosition().x
    bodyDef.position.y = @level.moto.left_wheel.GetPosition().y - Constants.left_wheel.radius

    bodyDef.userData =
      name: 'particle'

    bodyDef.type = b2Body.b2_dynamicBody

    # Assign fixture to body and add body to 2D world
    particle = @world.CreateBody(bodyDef)
    particle.CreateFixture(fixDef)

    particle.ApplyForce({x: -1, y: -1}, particle.GetWorldCenter())

    @list.push(particle)

  update: ->
    ctx = @level.ctx

    for particle in @list
      position = particle.GetPosition()

      ctx.save()
      ctx.translate(position.x, position.y)

      ctx.beginPath()
      ctx.arc(0, 0, 0.04, 0, 2*Math.PI)
      ctx.fill()

      ctx.restore()
