Circle = planck.Circle

class Particles

  constructor: (level, replay) ->
    @level   = level
    @physics = level.physics
    @world   = @physics.world
    @list    = []

  create: ->
    shape = new Circle(0.04)

    particle = @world.createBody({
      type:     'dynamic'
      position: {
        x: @level.moto.left_wheel.getPosition().x
        y: @level.moto.left_wheel.getPosition().y - Constants.left_wheel.radius
      }
      userData: {
        name: 'particle'
      }
    })

    particle.createFixture(shape, {
      density:          1.0
      restitution:      0.5
      friction:         1.0
      isSensor:         false
      filterGroupIndex: -1
    })

    particle.applyForce({x: -1, y: -1}, particle.getWorldCenter())

    @list.push(particle)

  update: ->
    ctx = @level.ctx

    for particle in @list
      position = particle.getPosition()

      ctx.save()
      ctx.translate(position.x, position.y)

      ctx.beginPath()
      ctx.arc(0, 0, 0.04, 0, 2*Math.PI)
      ctx.fill()

      ctx.restore()
