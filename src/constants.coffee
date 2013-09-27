b2Vec2 = Box2D.Common.Math.b2Vec2

class Constants

  # MOTO PARTS

  @body =
    density:     1.5
    restitution: 0.5
    friction:    1.0
    collision_box:
      v1: new b2Vec2( 0.6, -0.3)
      v2: new b2Vec2( 0.6,  0.4)
      v3: new b2Vec2(-0.7,  0.4)
      v4: new b2Vec2(-0.7, -0.3)

  @wheels =
    density:     2.0
    restitution: 0.5
    friction:    1.3

  @left_axle =
    density:     1.0
    restitution: 0.5
    friction:    1.0
    collision_box:
      v1: new b2Vec2(-0.10, -0.30)
      v2: new b2Vec2(-0.25, -0.30)
      v3: new b2Vec2(-0.80, -0.58)
      v4: new b2Vec2(-0.65, -0.58)

  @right_axle =
    density:     1.5
    restitution: 0.5
    friction:    1.0
    collision_box:
      v1: new b2Vec2(0.58, -0.02)
      v2: new b2Vec2(0.48, -0.02)
      v3: new b2Vec2(0.66, -0.58)
      v4: new b2Vec2(0.76, -0.58)

  # MOTO JOINTS

  @left_suspension =
    angle: new b2Vec2(0.1, 1)
    lower_translation: -0.10
    upper_translation:  0.20

  @right_suspension =
    angle: new b2Vec2(-0.1, 1)
    lower_translation: 0.00
    upper_translation: 0.20

  # RIDER PARTS

  @torso =
    density:     0.2
    restitution: 0.5
    friction:    1.0
    collision_box:
      v1: new b2Vec2( 0.25, -0.575)
      v2: new b2Vec2( 0.25,  0.575)
      v3: new b2Vec2(-0.25,  0.575)
      v4: new b2Vec2(-0.25, -0.575)
    angle: -Math.PI/20.0

  @lower_leg =
    density:     0.2
    restitution: 0.5
    friction:    1.0
    collision_box:
      v1: new b2Vec2( 0.2, -0.33)
      v2: new b2Vec2( 0.2,  0.33)
      v3: new b2Vec2(-0.2,  0.33)
      v4: new b2Vec2(-0.2, -0.33)
    angle: -Math.PI/6.0

  @upper_leg =
    density:     0.2
    restitution: 0.5
    friction:    1.0
    collision_box:
      v1: new b2Vec2( 0.4, -0.14)
      v2: new b2Vec2( 0.4,  0.14)
      v3: new b2Vec2(-0.4,  0.14)
      v4: new b2Vec2(-0.4, -0.14)
    angle: -Math.PI/12.0

  @lower_arm =
    density:     0.2
    restitution: 0.5
    friction:    1.0
    collision_box:
      v1: new b2Vec2( 0.28, -0.1)
      v2: new b2Vec2( 0.28,  0.1)
      v3: new b2Vec2(-0.28,  0.1)
      v4: new b2Vec2(-0.28, -0.1)
    angle: -Math.PI/10.0

  @upper_arm =
    density:     0.2
    restitution: 0.5
    friction:    1.0
    collision_box:
      v1: new b2Vec2( 0.125, -0.28)
      v2: new b2Vec2( 0.125,  0.28)
      v3: new b2Vec2(-0.125,  0.28)
      v4: new b2Vec2(-0.125, -0.28)
    angle: Math.PI/9.0

  # RIDER JOINTS

  @ankle =
    axe_position:
      x: -0.2
      y: -0.2

  @wrist =
    axe_position:
      x:  0.25
      y: -0.07

  @knee =
    axe_position:
      x:  0.07
      y:  0.28

  @elbow =
    axe_position:
      x:  0.05
      y: -0.2

  @shoulder =
    axe_position:
      x: -0.12
      y:  0.22

  @hip =
    axe_position:
      x: -0.27
      y:  0.10
