class Math2D

  @distance_between_points: (point1, point2) ->
    a = Math.pow(point1.x - point2.x, 2)
    b = Math.pow(point1.y - point2.y, 2)
    Math.sqrt(a+b)

  @angle_between_points: (point1, point2) ->
    adj = point2.x - point1.x
    opp = point2.y - point1.y

    angle = Math.abs(Math.atan(opp/adj) * 180/Math.PI)

    if adj > 0 && opp < 0
      angle = 90 - angle
    else if adj >= 0 && opp >= 0
      angle += 90
    else if adj < 0 && opp >= 0
      angle = 180 + (90 - angle)
    else
      angle += 270

    angle * Math.PI / 180.0 # radians

  # Rotate point from angle around axe
  @rotate_point: (point, angle, rotation_axe) ->
    new_point =
      x: rotation_axe.x + point.x * Math.cos(angle) - point.y * Math.sin(angle)
      y: rotation_axe.y + point.x * Math.sin(angle) + point.y * Math.cos(angle)

  @invalid_shape: (vertices) ->
    for vertex in vertices
      vertex.x = vertex.x + 0.5/100 - Math.random()/100
      vertex.y = vertex.y + 0.5/100 - Math.random()/100

    false
