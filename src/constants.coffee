b2Vec2 = Box2D.Common.Math.b2Vec2

class Constants

  # GENERAL

  @debug             = false
  @gravity           =  9.81 # Default gravity of the game
  @max_moto_speed    = 70.00 # Max rotation speed of the wheels. Limit the max speed of the moto
  @air_density       =  0.03 # Friction of air
  @moto_acceleration =  8.00 # Acceleration of moto
  @biker_force       =  6.00 # Force of biker when he rotates the moto

  # FRAMERATE

  @fps        = 60.0
  @replay_fps = 10.0 # "fps / replay_fps = x" where x is an integer !

  # DISPLAY

  @automatic_scale = true # camera zoom and dezoom when moto speed changes         (can be both)
  @manual_scale    = true # camera zoom and dezoom when player scrolls up and down (can be both)
  @default_scale   =      # default zoom of the camera
    x:  85.0
    y: -85.0

  # PATHS TO BACKEND

  @scores_path  = '/level_user_links'  # Path where to POST a score
  @replays_path = '/data/Replays'      # Path where all the replay files are stored (ex. /data/Replays/1.replay)
                                       # ...for better performances, replay files are publicly stored (flat !)

  # SELECTORS FOR BACKEND (get important informations from the page DOM)

  @current_user_selector      = "#current-user"         # ex. $("#current-user").attr('data-best-score-id')
  @best_score_id_attribute    = "data-best-score-id"    #     must give the id from the current user's best score
  @best_score_steps_attribute = "data-best-score-steps" #     so that we can load the corresponding replay

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
    restitution: 0.5
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
    restitution: 0.5
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
    collisions: true
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
    collisions: false
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

  # OVERRIDE CONSTANTS BY URL PARAMS

  url = $.url()

  # General
  @debug             = url.param('debug') == 'true'               if url.param('debug')
  @gravity           = parseFloat(url.param('gravity'))           if url.param('gravity')
  @max_moto_speed    = parseFloat(url.param('max_moto_speed'))    if url.param('max_moto_speed')
  @air_density       = parseFloat(url.param('air_density'))       if url.param('air_density')
  @automatic_scale   = url.param('automatic_scale') == 'true'     if url.param('automatic_scale')
  @manual_scale      = url.param('manual_scale')    == 'true'     if url.param('manual_scale')
  @moto_acceleration = parseFloat(url.param('moto_acceleration')) if url.param('moto_acceleration')
  @biker_force       = parseFloat(url.param('biker_force'))       if url.param('biker_force')

  # Density
  @body.density        = parseFloat(url.param('body_density'))        if url.param('body_density')
  @left_wheel.density  = parseFloat(url.param('left_wheel_density'))  if url.param('left_wheel_density')
  @right_wheel.density = parseFloat(url.param('right_wheel_density')) if url.param('right_wheel_density')
  @left_axle.density   = parseFloat(url.param('left_axle_density'))   if url.param('left_axle_density')
  @right_axle.density  = parseFloat(url.param('right_axle_density'))  if url.param('right_axle_density')
  @head.density        = parseFloat(url.param('head_density'))        if url.param('head_density')
  @torso.density       = parseFloat(url.param('torso_density'))       if url.param('torso_density')
  @lower_leg.density   = parseFloat(url.param('lower_leg_density'))   if url.param('lower_leg_density')
  @upper_leg.density   = parseFloat(url.param('upper_leg_density'))   if url.param('upper_leg_density')
  @lower_arm.density   = parseFloat(url.param('lower_arm_density'))   if url.param('lower_arm_density')
  @upper_arm.density   = parseFloat(url.param('upper_arm_density'))   if url.param('upper_arm_density')

  # Restitution
  @body.restitution        = parseFloat(url.param('body_restitution'))        if url.param('body_restitution')
  @left_wheel.restitution  = parseFloat(url.param('left_wheel_restitution'))  if url.param('left_wheel_restitution')
  @right_wheel.restitution = parseFloat(url.param('right_wheel_restitution')) if url.param('right_wheel_restitution')
  @left_axle.restitution   = parseFloat(url.param('left_axle_restitution'))   if url.param('left_axle_restitution')
  @right_axle.restitution  = parseFloat(url.param('right_axle_restitution'))  if url.param('right_axle_restitution')
  @head.restitution        = parseFloat(url.param('head_restitution'))        if url.param('head_restitution')
  @torso.restitution       = parseFloat(url.param('torso_restitution'))       if url.param('torso_restitution')
  @lower_leg.restitution   = parseFloat(url.param('lower_leg_restitution'))   if url.param('lower_leg_restitution')
  @upper_leg.restitution   = parseFloat(url.param('upper_leg_restitution'))   if url.param('upper_leg_restitution')
  @lower_arm.restitution   = parseFloat(url.param('lower_arm_restitution'))   if url.param('lower_arm_restitution')
  @upper_arm.restitution   = parseFloat(url.param('upper_arm_restitution'))   if url.param('upper_arm_restitution')

  # Friction
  @body.friction        = parseFloat(url.param('body_friction'))        if url.param('body_friction')
  @left_wheel.friction  = parseFloat(url.param('left_wheel_friction'))  if url.param('left_wheel_friction')
  @right_wheel.friction = parseFloat(url.param('right_wheel_friction')) if url.param('right_wheel_friction')
  @left_axle.friction   = parseFloat(url.param('left_axle_friction'))   if url.param('left_axle_friction')
  @right_axle.friction  = parseFloat(url.param('right_axle_friction'))  if url.param('right_axle_friction')
  @head.friction        = parseFloat(url.param('head_friction'))        if url.param('head_friction')
  @torso.friction       = parseFloat(url.param('torso_friction'))       if url.param('torso_friction')
  @lower_leg.friction   = parseFloat(url.param('lower_leg_friction'))   if url.param('lower_leg_friction')
  @upper_leg.friction   = parseFloat(url.param('upper_leg_friction'))   if url.param('upper_leg_friction')
  @lower_arm.friction   = parseFloat(url.param('lower_arm_friction'))   if url.param('lower_arm_friction')
  @upper_arm.friction   = parseFloat(url.param('upper_arm_friction'))   if url.param('upper_arm_friction')

  # Collision
  @body.collision        = url.param('body_collision')        == 'true' if url.param('body_collision')
  @left_wheel.collision  = url.param('left_wheel_collision')  == 'true' if url.param('left_wheel_collision')
  @right_wheel.collision = url.param('right_wheel_collision') == 'true' if url.param('right_wheel_collision')
  @left_axle.collision   = url.param('left_axle_collision')   == 'true' if url.param('left_axle_collision')
  @right_axle.collision  = url.param('right_axle_collision')  == 'true' if url.param('right_axle_collision')
  @head.collision        = url.param('head_collision')        == 'true' if url.param('head_collision')
  @torso.collision       = url.param('torso_collision')       == 'true' if url.param('torso_collision')
  @lower_leg.collision   = url.param('lower_leg_collision')   == 'true' if url.param('lower_leg_collision')
  @upper_leg.collision   = url.param('upper_leg_collision')   == 'true' if url.param('upper_leg_collision')
  @lower_arm.collision   = url.param('lower_arm_collision')   == 'true' if url.param('lower_arm_collision')
  @upper_arm.collision   = url.param('upper_arm_collision')   == 'true' if url.param('upper_arm_collision')

  # Others
  @head.radius                        = parseFloat(url.param('head_radius'))                        if url.param('head_radius')

  @left_suspension.angle.x            = parseFloat(url.param['left_suspension_angle_x'])            if url.param('left_suspension_angle_x')
  @left_suspension.angle.y            = parseFloat(url.param['left_suspension_angle_y'])            if url.param('left_suspension_angle_y')
  @left_suspension.lower_translation  = parseFloat(url.param['left_suspension_lower_translation'])  if url.param('left_suspension_lower_translation')
  @left_suspension.upper_translation  = parseFloat(url.param['left_suspension_upper_translation'])  if url.param('left_suspension_upper_translation')

  @right_suspension.angle.x           = parseFloat(url.param['right_suspension_angle_x'])           if url.param('right_suspension_angle_x')
  @right_suspension.angle.y           = parseFloat(url.param['right_suspension_angle_y'])           if url.param('right_suspension_angle_y')
  @right_suspension.lower_translation = parseFloat(url.param['right_suspension_lower_translation']) if url.param('right_suspension_lower_translation')
  @right_suspension.upper_translation = parseFloat(url.param['right_suspension_upper_translation']) if url.param('right_suspension_upper_translation')

