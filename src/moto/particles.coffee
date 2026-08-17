Circle = planck.Circle

class Particles

  constructor: (level, replay) ->
    @level   = level
    @physics = level.physics
    @world   = @physics.world
    @list    = []

  create: ->
    position =
      x: @level.moto.left_wheel.getPosition().x
      y: @level.moto.left_wheel.getPosition().y - Constants.left_wheel.radius

    user_data =
      name: 'particle'

    particle = @level.physics.create_circle(0.04, position, 0, 'dynamic', user_data, {
      density:            1.0
      restitution:        0.5
      friction:           1.0
      is_sensor:          false
      filter_group_index: -1 # Don't collide with moto/rider or themselves
    })


    particle.applyForce({x: -1.0, y: 1.0}, particle.getWorldCenter())

    @list.push(particle)

  update: ->

