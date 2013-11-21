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
    collision_box: [ new b2Vec2( 0.4, -0.3)
                     new b2Vec2( 0.56,  0.45)
                     new b2Vec2(-0.83,  0.2)
                     new b2Vec2(-0.35, -0.3) ]

  @wheels =
    density:     2.0
    restitution: 0.5
    friction:    1.3
    position:
      x: 0.70
      y: 0.48

  @left_axle =
    density:     1.0
    restitution: 0.5
    friction:    1.0
    position:
      x: 0.0
      y: 1.0
    collision_box: [ new b2Vec2(-0.10, -0.30)
                     new b2Vec2(-0.25, -0.30)
                     new b2Vec2(-0.80, -0.58)
                     new b2Vec2(-0.65, -0.58) ]

  @right_axle =
    density:     1.5
    restitution: 0.5
    friction:    1.0
    position:
      x: 0.0
      y: 1.0
    collision_box: [ new b2Vec2(0.58, -0.02)
                     new b2Vec2(0.48, -0.02)
                     new b2Vec2(0.66, -0.58)
                     new b2Vec2(0.76, -0.58) ]

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

  @torso =
    density:     0.4
    restitution: 0.0
    friction:    1.0
    position:
      x: -0.24
      y:  1.87
    collision_box: [ new b2Vec2( 0.16, -0.575)
                     new b2Vec2( 0.23,  0.50)
                     new b2Vec2(-0.20,  0.48)
                     new b2Vec2(-0.17, -0.575) ]
    angle: -Math.PI/20.0

  @lower_leg =
    density:     0.4
    restitution: 0.0
    friction:    1.0
    position:
      x: 0.15
      y: 0.90
    collision_box: [ new b2Vec2( 0.2, -0.33)
                     new b2Vec2( 0.2, -0.27)
                     new b2Vec2( 0.00  , -0.2)
                     new b2Vec2( 0.02,  0.33)
                     new b2Vec2(-0.17,  0.33)
                     new b2Vec2(-0.14, -0.33) ]
    angle: -Math.PI/6.0

  @upper_leg =
    density:     0.4
    restitution: 0.0
    friction:    1.0
    position:
      x: - 0.09
      y:   1.27
    collision_box: [ new b2Vec2( 0.4, -0.14)
                     new b2Vec2( 0.4,  0.07)
                     new b2Vec2(-0.4,  0.14)
                     new b2Vec2(-0.4, -0.08) ]
    angle: -Math.PI/12.0

  @lower_arm =
    density:     0.4
    restitution: 0.0
    friction:    1.0
    position:
      x: 0.07
      y: 1.52
    collision_box: [ new b2Vec2( 0.28, -0.055)
                     new b2Vec2( 0.28,  0.055)
                     new b2Vec2(-0.28,  0.08)
                     new b2Vec2(-0.28, -0.05) ]
    angle: -Math.PI/10.0

  @upper_arm =
    density:     0.4
    restitution: 0.0
    friction:    1.0
    position:
      x: -0.17
      y:  1.83
    collision_box: [ new b2Vec2( 0.09, -0.26)
                     new b2Vec2( 0.09,  0.26)
                     new b2Vec2(-0.11,  0.26)
                     new b2Vec2(-0.11, -0.26) ]
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

  # xmoto c++ version constants
  @cpp =
    rider_hand:
      x: 0.3
      y: 0.45
    rider_foot:
      x: 0.0
      y: -0.37
    rider_head_size: 0.18
    rider_neck_length: 0.22


#      /* torso */
#      renderBodyPart(pBike->Dir == DD_RIGHT ? pBike->ShoulderP  : pBike->Shoulder2P,
#		     pBike->Dir == DD_RIGHT ? pBike->LowerBodyP : pBike->LowerBody2P,
#		     0.24, 0.46,
#		     0.24, -0.1,
#		     0.24, -0.1,
#		     0.24, 0.46,
#		     p_theme->getTorso(),
#		     i_filterColor,
#		     i_biker
#		     );
#
#      /* upper leg */
#      renderBodyPart(pBike->Dir == DD_RIGHT ? pBike->LowerBodyP : pBike->LowerBody2P,
#		     pBike->Dir == DD_RIGHT ? pBike->KneeP      : pBike->Knee2P,
#		     0.20, 0.14,
#		     0.15, 0.00,
#		     0.15, 0.00,
#		     0.10, 0.14,
#		     p_theme->getUpperLeg(),
#		     i_filterColor,
#		     i_biker, 1
#		     );
#
#      /* lower leg */
#      renderBodyPart(pBike->Dir == DD_RIGHT ? pBike->KneeP : pBike->Knee2P,
#		     pBike->Dir == DD_RIGHT ? pBike->FootP : pBike->Foot2P,
#		     0.23, 0.01,
#		     0.20, 0.00,
#		     0.20, 0.00,
#		     0.23, 0.10,
#		     p_theme->getLowerLeg(),
#		     i_filterColor,
#		     i_biker
#		     );
#
#      /* upper arm */
#      renderBodyPart(pBike->Dir == DD_RIGHT ? pBike->ShoulderP : pBike->Shoulder2P,
#		     pBike->Dir == DD_RIGHT ? pBike->ElbowP    : pBike->Elbow2P,
#		     0.12, 0.09,
#		     0.12, -0.05,
#		     0.10, -0.05,
#		     0.10, 0.09,
#		     p_theme->getUpperArm(),
#		     i_filterColor,
#		     i_biker
#		     );
#
#      /* lower arm */
#      renderBodyPart(pBike->Dir == DD_RIGHT ? pBike->ElbowP : pBike->Elbow2P,
#		     pBike->Dir == DD_RIGHT ? pBike->HandP  : pBike->Hand2P,
#		     0.12, 0.09,
#		     0.12, -0.05,
#		     0.10, -0.05,
#		     0.10, 0.09,
#		     p_theme->getLowerArm(),
#		     i_filterColor,
#		     i_biker, 2
#		     );
#  void GameRenderer::renderBodyPart(const Vector2f& i_from, const Vector2f& i_to,
#				    float i_c11, float i_c12,
#				    float i_c21, float i_c22,
#				    float i_c31, float i_c32,
#				    float i_c41, float i_c42,
#				    Sprite* i_sprite,
#				    const TColor& i_filterColor,
#				    Biker* i_biker,
#				    int i_90_rotation
#				    ) {
#    Texture *pTexture;
#    Vector2f Sv;
#    Vector2f p0, p1, p2, p3;
#
#    if(i_sprite == NULL)
#      return;
#    pTexture = i_sprite->getTexture(false, false, FM_LINEAR); // FM_LINEAR
#    if(pTexture == NULL)
#      return;
#
#    Sv = i_from - i_to;
#    Sv.normalize();
#
#    if(i_biker->getState()->Dir == DD_RIGHT) {
#      p0 = i_from + Vector2f(-Sv.y, Sv.x) * i_c11 + Sv * i_c12;
#      p1 = i_to   + Vector2f(-Sv.y, Sv.x) * i_c21 + Sv * i_c22;
#      p2 = i_to   - Vector2f(-Sv.y, Sv.x) * i_c31 + Sv * i_c32;
#      p3 = i_from - Vector2f(-Sv.y, Sv.x) * i_c41 + Sv * i_c42;
#    } else {
#      p0 = i_from - Vector2f(-Sv.y, Sv.x) * i_c11 + Sv * i_c12;
#      p1 = i_to   - Vector2f(-Sv.y, Sv.x) * i_c21 + Sv * i_c22;
#      p2 = i_to   + Vector2f(-Sv.y, Sv.x) * i_c31 + Sv * i_c32;
#      p3 = i_from + Vector2f(-Sv.y, Sv.x) * i_c41 + Sv * i_c42;
#    }
#
#    p0 = calculateChangeDirPosition(i_biker,p0);
#    p1 = calculateChangeDirPosition(i_biker,p1);
#    p2 = calculateChangeDirPosition(i_biker,p2);
#    p3 = calculateChangeDirPosition(i_biker,p3);
#    
#    switch(i_90_rotation) {
#      case 0:
#      _RenderAlphaBlendedSection(pTexture, p1, p2, p3, p0, i_filterColor);
#      break;
#      case 1:
#      _RenderAlphaBlendedSection(pTexture, p0, p1, p2, p3, i_filterColor);
#      break;
#      case 2:
#      _RenderAlphaBlendedSection(pTexture, p3, p2, p1, p0, i_filterColor);
#      break;
#    }
#  }
