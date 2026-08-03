
class Constants

  # GENERAL

  @debug             = false # Panel on the right to debug everything
  @debug_physics     = false # "Ugly" mode to debug physics
  @debug_culling     = false # Debug culling of sprites
  @hooking           = false # Hooking is a special trick in XMoto that allow the bike
                             # to "hook" on blocks (http://www.youtube.com/watch?v=ebCgtnm_1m0)
                             # (no collisions and no kill except for head)
  @gravity           =  9.81 # Default gravity of the game
  @max_moto_speed    = 70.00 # Max rotation speed of the wheels. Limit the max speed of the moto
  @air_density       =  0.02 # Friction of air
  @moto_acceleration =  9.00 # Acceleration of moto
  @biker_force       = 11.00 # Force of biker when he rotates the moto

  # REPLAYS

  @replay_key_step = 60          # Key step every x steps during replay (to beat non-deterministic behaviour)
                                 # See https://github.com/MichaelHoste/xmoto.js/issues/8
  @replay_key_step_precision = 4 # Number of decimals when saving key step position

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
    vertices: [
      { x:  0.40, y: -0.30 }
      { x:  0.50, y:  0.40 }
      { x: -0.75, y:  0.16 }
      { x: -0.35, y: -0.30 }
    ]
    collisions: true
    texture:       'playerbikerbody.png'
    ghost_texture: 'ghostbikerbody.png'
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
    texture:       'playerbikerwheel.png'
    ghost_texture: 'ghostbikerwheel.png'

  @right_wheel =
    radius:      0.35
    density:     1.8
    restitution: 0.3
    friction:    1.4
    position:
      x: 0.70
      y: 0.48
    collisions: true
    texture:       'playerbikerwheel.png'
    ghost_texture: 'ghostbikerwheel.png'

  @left_axle =
    density:     1.0
    restitution: 0.5
    friction:    1.0
    position:
      x: 0.0
      y: 1.0
    vertices: [
      { x: -0.10, y: -0.30 }
      { x: -0.25, y: -0.30 }
      { x: -0.80, y: -0.58 }
      { x: -0.65, y: -0.58 }
    ]
    collisions: true
    texture:       'rear1.png'
    ghost_texture: 'rear_ghost.png'

  @right_axle =
    density:     1.5
    restitution: 0.5
    friction:    1.0
    position:
      x: 0.0
      y: 1.0
    vertices: [
      { x: 0.58, y: -0.02 }
      { x: 0.48, y: -0.02 }
      { x: 0.66, y: -0.58 }
      { x: 0.76, y: -0.58 }
    ]
    collisions: true
    texture:       'front1.png'
    ghost_texture: 'front_ghost.png'

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
    vertices: [
      { x:  0.10, y: -0.55 }
      { x:  0.13, y:  0.15 }
      { x: -0.20, y:  0.22 }
      { x: -0.18, y: -0.55 }
    ]
    collisions: true
    texture:       'playertorso.png'
    ghost_texture: 'ghosttorso.png'
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
    vertices: [
      { x:  0.20, y: -0.33 }
      { x:  0.20, y: -0.27 }
      { x:  0.00, y: -0.20 }
      { x:  0.02, y:  0.33 }
      { x: -0.17, y:  0.33 }
      { x: -0.14, y: -0.33 }
    ]
    collisions: true
    texture:       'playerlowerleg.png'
    ghost_texture: 'ghostlowerleg.png'
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
    vertices: [
      { x:  0.4, y: -0.14 }
      { x:  0.4, y:  0.07 }
      { x: -0.4, y:  0.14 }
      { x: -0.4, y: -0.08 }
    ]
    collisions: true
    texture:       'playerupperleg.png'
    ghost_texture: 'ghostupperleg.png'
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
    vertices: [
      { x:  0.28, y: -0.07 }
      { x:  0.28, y:  0.04 }
      { x: -0.30, y:  0.07 }
      { x: -0.30, y: -0.06 }
    ]
    collisions: true
    texture:       'playerlowerarm.png'
    ghost_texture: 'ghostlowerarm.png'
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
    vertices: [
      { x:  0.09, y: -0.29 }
      { x:  0.09, y:  0.22 }
      { x: -0.11, y:  0.26 }
      { x: -0.10, y: -0.29 }
    ]
    collisions: true
    texture:       'playerupperarm.png'
    ghost_texture: 'ghostupperarm.png'
    texture_size:
      x: 0.24
      y: 0.56

  # MOTO JOINTS

  @left_suspension =
    angle:
      x: 0.0,
      y: 1.0
    lower_translation: -0.03
    upper_translation:  0.20
    back_force:         3.00
    rigidity:           8.00

  @right_suspension =
    angle:
      x: -0.2
      y:  1.0
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
