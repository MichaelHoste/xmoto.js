b2Vec2 = Box2D.Common.Math.b2Vec2

class Constants

  # GENERAL

  @debug             = false # "Ugly" mode to debug physics
  @hooking           = false # Hooking is a special trick in XMoto that allow the bike
                             # to "hook" on blocks (http://www.youtube.com/watch?v=ebCgtnm_1m0)
                             # (no collisions and no kill except for head)
  @gravity           =  9.81 # Default gravity of the game
  @max_moto_speed    = 70.00 # Max rotation speed of the wheels. Limit the max speed of the moto
  @air_density       =  0.03 # Friction of air
  @moto_acceleration =  9.00 # Acceleration of moto
  @biker_force       = 11.00 # Force of biker when he rotates the moto

  # FRAMERATE

  @fps        = 60.0
  @replay_fps = 10.0 # "fps / replay_fps = x" where x is an integer !

  # DISPLAY

  @automatic_scale = true # camera zoom and dezoom when moto speed changes         (can be both)
  @manual_scale    = true # camera zoom and dezoom when player scrolls up and down (can be both)
  @default_scale   =      # default zoom of the camera
    x:  70.0
    y: -70.0

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
    texture:       'playerbikerbody'
    ghost_texture: 'ghostbikerbody'
    texture_size:
      x: 2.0
      y: 1.0

  @left_wheel =
    radius:      0.35
    density:     1.8
    restitution: 0.3
    friction:    1.4
    position:
      x: -0.70
      y:  0.48
    collisions: true
    texture:       'playerbikerwheel'
    ghost_texture: 'ghostbikerwheel'

  @right_wheel =
    radius:      0.35
    density:     1.8
    restitution: 0.3
    friction:    1.4
    position:
      x: 0.70
      y: 0.48
    collisions: true
    texture:       'playerbikerwheel'
    ghost_texture: 'ghostbikerwheel'

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
    texture:       'rear1'
    ghost_texture: 'rear_ghost'

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
    texture:       'front1'
    ghost_texture: 'front_ghost'

  # RIDER PARTS

  @head =
    density:     0.4
    restitution: 0.0
    friction:    1.0
    position:
      x: -0.27
      y:  2.26
    radius:     0.18
    collisions: true

  @torso =
    density:     0.4
    restitution: 0.0
    friction:    1.0
    position:
      x: -0.31
      y:  1.89
    angle: -Math.PI/30.0
    shape: [ new b2Vec2( 0.10, -0.55)
             new b2Vec2( 0.13,  0.15)
             new b2Vec2(-0.20,  0.22)
             new b2Vec2(-0.18, -0.55) ]
    collisions: (true)
    texture:       'playertorso'
    ghost_texture: 'ghosttorso'
    texture_size:
      x: 0.50
      y: 1.20

  @lower_leg =
    density:     0.4
    restitution: 0.0
    friction:    1.0
    position:
      x: 0.07
      y: 0.90
    angle: -Math.PI/6.0
    shape: [ new b2Vec2( 0.2,  -0.33)
             new b2Vec2( 0.2,  -0.27)
             new b2Vec2( 0.00, -0.2)
             new b2Vec2( 0.02,  0.33)
             new b2Vec2(-0.17,  0.33)
             new b2Vec2(-0.14, -0.33) ]
    collisions: true
    texture:       'playerlowerleg'
    ghost_texture: 'ghostlowerleg'
    texture_size:
      x: 0.40
      y: 0.66

  @upper_leg =
    density:     0.4
    restitution: 0.0
    friction:    1.0
    position:
      x: -0.15
      y:  1.27
    angle: -Math.PI/11.0
    shape: [ new b2Vec2( 0.4, -0.14)
             new b2Vec2( 0.4,  0.07)
             new b2Vec2(-0.4,  0.14)
             new b2Vec2(-0.4, -0.08) ]
    collisions: true
    texture:       'playerupperleg'
    ghost_texture: 'ghostupperleg'
    texture_size:
      x: 0.78
      y: 0.28

  @lower_arm =
    density:     0.4
    restitution: 0.0
    friction:    1.0
    position:
      x: 0.07
      y: 1.54
    angle: -Math.PI/10.0
    shape: [ new b2Vec2( 0.28, -0.07)
             new b2Vec2( 0.28,  0.04)
             new b2Vec2(-0.30,  0.07)
             new b2Vec2(-0.30, -0.06) ]
    collisions: true
    texture:       'playerlowerarm'
    ghost_texture: 'ghostlowerarm'
    texture_size:
      x: 0.53
      y: 0.20

  @upper_arm =
    density:     0.4
    restitution: 0.0
    friction:    1.0
    position:
      x: -0.20
      y:  1.85
    angle: Math.PI/10.0
    shape: [ new b2Vec2( 0.09, -0.29)
             new b2Vec2( 0.09,  0.22)
             new b2Vec2(-0.11,  0.26)
             new b2Vec2(-0.10, -0.29) ]
    collisions: true
    texture:       'playerupperarm'
    ghost_texture: 'ghostupperarm'
    texture_size:
      x: 0.24
      y: 0.56

  # MOTO JOINTS

  @left_suspension =
    angle: new b2Vec2(0, 1)
    lower_translation: -0.03
    upper_translation:  0.20
    back_force:         3.00
    rigidity:           8.00

  @right_suspension =
    angle: new b2Vec2(-0.2, 1)
    lower_translation: -0.01
    upper_translation:  0.20
    back_force:         3.00
    rigidity:           4.00

  # RIDER JOINTS

  @ankle =
    axe_position:
      x: -0.18
      y: -0.2

  @wrist =
    axe_position:
      x:  0.25
      y: -0.07

  @knee =
    axe_position:
      x:  0.12
      y:  0.28

  @elbow =
    axe_position:
      x:  0.03
      y: -0.21

  @shoulder =
    axe_position:
      x: -0.12
      y:  0.22

  @hip =
    axe_position:
      x: -0.25
      y:  0.14

  # GROUND

  @ground =
    density:     1.0
    restitution: 0.2
    friction:    1.2

  # CHAIN REACTION OF SOME ATTRIBUTES

  @chain_reaction: ->
    # If hooking == true, no collisions !
    if @hooking == true
      for element in ['body', 'left_axle', 'right_axle', 'torso',
                      'lower_leg', 'upper_leg', 'lower_arm', 'upper_arm']
        Constants[element].collisions = false

  @chain_reaction()
