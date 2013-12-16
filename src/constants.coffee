b2Vec2 = Box2D.Common.Math.b2Vec2

class Constants

  @init: ->
  
    # GENERAL
  
    @gravity = CppConstants.world.gravity
    @max_rotation_speed = 0.38 # Max rotation speed of the wheels (x * PI). Limit the max speed of the moto
    @air_density        = 0.03
  
    # MOTO PARTS
  
    @body =
      density:     1.5
      restitution: 0.5
      friction:    1.0
      position:    CppConstants.moto.body.position
      shape: [ new b2Vec2( 0.10, -0.4)
               new b2Vec2( 0.50,  0.2)
               new b2Vec2(-0.98,  0.22)
               new b2Vec2(-0.15, -0.4) ]
      collisions: true
  
    @wheels =
      radius:      CppConstants.moto.wheel.radius
      density:     2.0
      restitution: 0.5
      friction:    1.3
      position:    CppConstants.moto.wheel.position
      collisions: true
  
    @left_axle =
      density:     1.0
      restitution: 0.5
      friction:    1.0
      position:
        x: 0.05
        y: 1.15
      shape: [ new b2Vec2(-0.10, -0.55)
               new b2Vec2(-0.25, -0.55)
               new b2Vec2(-0.80, -0.78)
               new b2Vec2(-0.65, -0.78) ]
      collisions: true
  
    @right_axle =
      density:     1.5
      restitution: 0.5
      friction:    1.0
      position:
        x: -0.01
        y: 1.15
      shape: [ new b2Vec2(0.50, -0.02)
               new b2Vec2(0.40, -0.02)
               new b2Vec2(0.58, -0.58)
               new b2Vec2(0.68, -0.58) ]
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
      radius:      CppConstants.rider.head.radius
      density:     0.001
      restitution: 0.0
      friction:    0.0
      position:    CppConstants.rider.head.position
      collisions: true
  
    @torso =
      density:     0.4
      restitution: 0.0
      friction:    1.0
      position:    CppConstants.rider.torso.position
      shape: [ new b2Vec2( 0.00, -0.34)
               new b2Vec2( 0.05,  0.39)
               new b2Vec2(-0.25,  0.44)
               new b2Vec2(-0.22, -0.34) ]
      collisions: true
      angle: -Math.PI/20.0
  
    @lower_leg =
      density:     0.4
      restitution: 0.0
      friction:    1.0
      position:    CppConstants.rider.lower_leg.position
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
      position:    CppConstants.rider.upper_leg.position
      shape: [ new b2Vec2( 0.25, -0.14)
               new b2Vec2( 0.25,  0.07)
               new b2Vec2(-0.40,  0.14)
               new b2Vec2(-0.40, -0.08) ]
      collisions: true
      angle: -Math.PI/12.0
  
    @lower_arm =
      density:     0.4
      restitution: 0.0
      friction:    1.0
      position:    CppConstants.rider.lower_arm.position
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
      position:    CppConstants.rider.upper_arm.position
      shape: [ new b2Vec2( 0.09, -0.26)
               new b2Vec2( 0.09,  0.26)
               new b2Vec2(-0.11,  0.26)
               new b2Vec2(-0.11, -0.26) ]
      collisions: true
      angle: Math.PI/9.0
  
    # RIDER JOINTS
  
    @ankle =
      axe_position: CppConstants.rider.ankle.axe
  
    @wrist =
      axe_position: CppConstants.rider.wrist.axe
  
    @knee =
      axe_position: CppConstants.rider.knee.axe
  
    @elbow =
      axe_position: CppConstants.rider.elbow.axe
  
    @shoulder =
      axe_position: CppConstants.rider.shoulder.axe
  
    @hip =
      axe_position: CppConstants.rider.hip.axe

