b2World         = Box2D.Dynamics.b2World
b2Vec2          = Box2D.Common.Math.b2Vec2
b2AABB          = Box2D.Collision.b2AABB
b2BodyDef       = Box2D.Dynamics.b2BodyDef
b2Body          = Box2D.Dynamics.b2Body
b2FixtureDef    = Box2D.Dynamics.b2FixtureDef
b2Fixture       = Box2D.Dynamics.b2Fixture
b2MassData      = Box2D.Collision.Shapes.b2MassData
b2PolygonShape  = Box2D.Collision.Shapes.b2PolygonShape
b2CircleShape   = Box2D.Collision.Shapes.b2CircleShape
b2DebugDraw     = Box2D.Dynamics.b2DebugDraw
b2MouseJointDef = Box2D.Dynamics.Joints.b2MouseJointDef

class Moto

  constructor: (level) ->
    @level  = level
    @assets = level.assets

  display: ->
    @display_left_wheel()

  init: ->
    # Assets
    textures = [ 'front1', 'lowerarm1', 'lowerleg1', 'playerbikerbody',
                 'playerbikerwheel', 'playerlowerarm', 'playerlowerleg',
                 'playertorso', 'playerupperarm', 'playerupperleg', 'rear1',
                 'upperarm1', 'upperleg1' ]
    for texture in textures
      @assets.moto.push(texture)

    # Creation of moto parts
    @left_wheel = @create_wheel(@level.entities.player_start.x, @level.entities.player_start.y, 1.0)

  create_wheel: (x, y, radius) ->
    # Create fixture
    fixDef = new b2FixtureDef()

    # Draw the object
    fixDef.shape = new b2CircleShape(radius / @level.physics.scale)

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = x / @level.physics.scale
    bodyDef.position.y = y / @level.physics.scale

    bodyDef.type = b2Body.b2_dynamicBody
    fixDef.density     = 1.0
    fixDef.restitution = 0.5
    fixDef.friction    = 1.0

    # Assign fixture to body and add body to 2D world
    @level.world.CreateBody(bodyDef).CreateFixture(fixDef)

  display_left_wheel: ->
    # Position
    position = @left_wheel.GetBody().GetPosition()
    scaled_position =
      x: position.x*@level.physics.scale
      y: position.y*@level.physics.scale

    # Radius
    radius = @left_wheel.GetShape().m_radius
    scaled_radius = radius*@level.physics.scale

    # Angle
    angle = @left_wheel.GetBody().GetAngle()

    # Draw texture
    @level.ctx.save()
    @level.ctx.translate(scaled_position.x, scaled_position.y)
    @level.ctx.rotate(angle)

    @level.ctx.drawImage(
      @assets.get('playerbikerwheel'), # texture
      -scaled_radius,   # x
       scaled_radius,   # y
       scaled_radius*2, # size-x
      -scaled_radius*2  # size-y
    )

    @level.ctx.restore()

