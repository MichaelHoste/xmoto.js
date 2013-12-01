b2Vec2 = Box2D.Common.Math.b2Vec2

class Constants

  # GENERAL

  @gravity = 9.81

  # MOTO PARTS

  @body =
    density:     1.5
    restitution: 0.5
    friction:    1.0
    position:
      x: 0.0
      y: 1.0
    shape: [ new b2Vec2( 0.4,  -0.3)
             new b2Vec2( 0.50,  0.40)
             new b2Vec2(-0.75,  0.16)
             new b2Vec2(-0.35, -0.3) ]
    collisions: true

  @wheels =
    radius:      0.35
    density:     2.0
    restitution: 0.5
    friction:    1.3
    position:
      x: 0.70
      y: 0.48
    collisions: true

  @left_axle =
    density:     1.0
    restitution: 0.5
    friction:    1.0
    position:
      x: 0.0
      y: 1.0
    shape: [ new b2Vec2(-0.10, -0.30)
             new b2Vec2(-0.25, -0.30)
             new b2Vec2(-0.80, -0.58)
             new b2Vec2(-0.65, -0.58) ]
    collisions: true

  @right_axle =
    density:     1.5
    restitution: 0.5
    friction:    1.0
    position:
      x: 0.0
      y: 1.0
    shape: [ new b2Vec2(0.58, -0.02)
             new b2Vec2(0.48, -0.02)
             new b2Vec2(0.66, -0.58)
             new b2Vec2(0.76, -0.58) ]
    collisions: true

  # MOTO JOINTS

  @left_suspension =
    angle: new b2Vec2(0, 1)
    lower_translation: -0.03
    upper_translation:  0.20

  @right_suspension =
    angle: new b2Vec2(-0.2, 1)
    lower_translation: 0.00
    upper_translation: 0.20

  # RIDER PARTS

  @head =
    radius:      0.18
    density:     0.001
    restitution: 0.0
    friction:    0.0
    position:
      x: -0.3
      y: 2.3
    collisions: true

  @torso =
    density:     0.4
    restitution: 0.0
    friction:    1.0
    position:
      x: -0.24
      y:  1.87
    shape: [ new b2Vec2( 0.16, -0.575)
             new b2Vec2( 0.07,  0.20)
             new b2Vec2(-0.34,  0.24)
             new b2Vec2(-0.20, -0.575) ]
    collisions: true
    angle: -Math.PI/20.0

  @lower_leg =
    density:     0.4
    restitution: 0.0
    friction:    1.0
    position:
      x: 0.15
      y: 0.90
    shape: [ new b2Vec2( 0.2,  -0.33)
             new b2Vec2( 0.2,  -0.27)
             new b2Vec2( 0.00, -0.2)
             new b2Vec2( 0.02,  0.33)
             new b2Vec2(-0.17,  0.33)
             new b2Vec2(-0.14, -0.33) ]
    collisions: true
    angle: -Math.PI/6.0

  @upper_leg =
    density:     0.4
    restitution: 0.0
    friction:    1.0
    position:
      x: - 0.09
      y:   1.27
    shape: [ new b2Vec2( 0.4, -0.14)
             new b2Vec2( 0.4,  0.07)
             new b2Vec2(-0.4,  0.14)
             new b2Vec2(-0.4, -0.08) ]
    collisions: true
    angle: -Math.PI/12.0

  @lower_arm =
    density:     0.4
    restitution: 0.0
    friction:    1.0
    position:
      x: 0.07
      y: 1.52
    shape: [ new b2Vec2( 0.28, -0.055)
             new b2Vec2( 0.28,  0.055)
             new b2Vec2(-0.28,  0.08)
             new b2Vec2(-0.28, -0.05) ]
    collisions: true
    angle: -Math.PI/10.0

  @upper_arm =
    density:     0.4
    restitution: 0.0
    friction:    1.0
    position:
      x: -0.17
      y:  1.83
    shape: [ new b2Vec2( 0.09, -0.26)
             new b2Vec2( 0.09,  0.26)
             new b2Vec2(-0.11,  0.26)
             new b2Vec2(-0.11, -0.26) ]
    collisions: true
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
