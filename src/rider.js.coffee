b2Vec2              = Box2D.Common.Math.b2Vec2
b2BodyDef           = Box2D.Dynamics.b2BodyDef
b2Body              = Box2D.Dynamics.b2Body
b2FixtureDef        = Box2D.Dynamics.b2FixtureDef
b2Fixture           = Box2D.Dynamics.b2Fixture
b2PolygonShape      = Box2D.Collision.Shapes.b2PolygonShape
b2CircleShape       = Box2D.Collision.Shapes.b2CircleShape
b2PrismaticJointDef = Box2D.Dynamics.Joints.b2PrismaticJointDef
b2RevoluteJointDef  = Box2D.Dynamics.Joints.b2RevoluteJointDef

class Rider

  constructor: (level, moto) ->
    @level  = level
    @assets = level.assets
    @moto   = moto

  display: ->
    @display_torso()
    @display_lower_leg()

  init: ->
    # Assets
    textures = [ 'playerlowerarm', 'playerlowerleg', 'playertorso',
                 'playerupperarm', 'playerupperleg', 'rear1' ]
    for texture in textures
      @assets.moto.push(texture)

    # Creation of moto parts
    @player_start = @level.entities.player_start
    @torso        = @create_torso(@player_start.x - 0.25, @player_start.y + 1.9)
    @lower_leg    = @create_lower_leg(@player_start.x + 0.15, @player_start.y + 0.9)

  position: ->
    @moto.body.GetPosition()

  create_torso: (x, y)  ->
    # Create fixture
    fixDef = new b2FixtureDef()

    fixDef.shape       = new b2PolygonShape()
    fixDef.density     = 1.0
    fixDef.restitution = 0.5
    fixDef.friction    = 1.0
    fixDef.filter.groupIndex = -1

    b2vertices = [ new b2Vec2(  0.25, -0.575),
                   new b2Vec2(  0.25,  0.575),
                   new b2Vec2( -0.25,  0.575),
                   new b2Vec2( -0.25, -0.575) ]

    fixDef.shape.SetAsArray(b2vertices)

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = x
    bodyDef.position.y = y

    #bodyDef.type = b2Body.b2_dynamicBody
    bodyDef.type = b2Body.b2_staticBody

    # Assign fixture to body and add body to 2D world
    body = @level.world.CreateBody(bodyDef)
    body.CreateFixture(fixDef)

    body

  create_lower_leg: (x, y) ->
    # Create fixture
    fixDef = new b2FixtureDef()

    fixDef.shape       = new b2PolygonShape()
    fixDef.density     = 1.0
    fixDef.restitution = 0.5
    fixDef.friction    = 1.0
    fixDef.filter.groupIndex = -1

    b2vertices = [ new b2Vec2(  0.2, -0.33),
                   new b2Vec2(  0.2,  0.33),
                   new b2Vec2( -0.2,  0.33),
                   new b2Vec2( -0.2, -0.33) ]

    fixDef.shape.SetAsArray(b2vertices)

    # Create body
    bodyDef = new b2BodyDef()

    # Assign body position
    bodyDef.position.x = x
    bodyDef.position.y = y

    # Assign body angle
    bodyDef.angle = -Math.PI/6.0

    #bodyDef.type = b2Body.b2_dynamicBody
    bodyDef.type = b2Body.b2_staticBody

    # Assign fixture to body and add body to 2D world
    body = @level.world.CreateBody(bodyDef)
    body.CreateFixture(fixDef)

    body

  display_torso: ->
    # Position
    position = @torso.GetPosition()

    # Angle
    angle = @torso.GetAngle()

    # Draw texture
    @level.ctx.save()
    @level.ctx.translate(position.x, position.y)
    @level.ctx.scale(1, -1)
    @level.ctx.rotate(-angle)

    @level.ctx.drawImage(
      @assets.get('playertorso'), # texture
      -0.25,   # x
      -0.575, # y
       0.5,   # size-x
       1.15   # size-y
    )

    @level.ctx.restore()

  display_lower_leg: ->
    # Position
    position = @lower_leg.GetPosition()

    # Angle
    angle = @lower_leg.GetAngle()

    # Draw texture
    @level.ctx.save()
    @level.ctx.translate(position.x, position.y)
    @level.ctx.scale(1, -1)
    @level.ctx.rotate(-angle)

    @level.ctx.drawImage(
      @assets.get('playerlowerleg'), # texture
      -0.2,  # x
      -0.33, # y
       0.40, # size-x
       0.66  # size-y
    )

    @level.ctx.restore()
