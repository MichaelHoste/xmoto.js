b2Vec2          = Box2D.Common.Math.b2Vec2
b2AABB          = Box2D.Collision.b2AABB

class Edges

  constructor: (level, blocks) ->
    @level  = level
    @assets = @level.assets
    @theme  = @assets.theme
    @blocks = blocks

    @list   = [] # List of edges

    # Assets
    for block in @blocks
      for vertex in block.vertices
        if vertex.edge
          @assets.effects.push(@theme.edge_params(vertex.edge).file)

    # Create edges
    for block in @blocks
      for vertex, i in block.vertices
        if vertex.edge
          edge =
            vertex1: vertex
            vertex2: if i == block.vertices.length-1 then block.vertices[0] else block.vertices[i+1]
            block:   block
            texture: vertex.edge
            theme:   @theme.edge_params(vertex.edge)
          edge.angle = Math2D.angle_between_points(edge.vertex1, edge.vertex2) - Math.PI/2
          edge.vertices = [ { x: edge.vertex1.absolute_x, y: edge.vertex1.absolute_y - edge.theme.depth },
                            { x: edge.vertex2.absolute_x, y: edge.vertex2.absolute_y - edge.theme.depth },
                            { x: edge.vertex2.absolute_x, y: edge.vertex2.absolute_y },
                            { x: edge.vertex1.absolute_x, y: edge.vertex1.absolute_y } ]
          edge.aabb = edge_AABB(edge)

          @list.push(edge)

  # only display edges present on the screen zone
  display: (ctx) ->
    for edge in @list
      if visible_edge(@level.visible, edge)
        ctx.beginPath()

        ctx.moveTo(edge.vertices[0].x, edge.vertices[0].y)
        ctx.lineTo(edge.vertices[1].x, edge.vertices[1].y)
        ctx.lineTo(edge.vertices[2].x, edge.vertices[2].y)
        ctx.lineTo(edge.vertices[3].x, edge.vertices[3].y)

        ctx.closePath()

        ctx.save()
        ctx.translate(edge.vertex1.absolute_x, edge.vertex1.absolute_y) # Always start texture on the left vertex
        ctx.rotate(edge.angle)
        ctx.scale(1.0 / 100, -1.0 / 100)
        ctx.fillStyle = ctx.createPattern(@assets.get(edge.theme.file), 'repeat')
        ctx.fill()
        ctx.restore()

edge_AABB = (edge) ->
  first = true
  lower_bound = {}
  upper_bound = {}
  for vertex in edge.vertices
    if first
      lower_bound =
        x: vertex.x
        y: vertex.y
      upper_bound =
        x: vertex.x
        y: vertex.y
      first = false
    else
      lower_bound.x = vertex.x if vertex.x < lower_bound.x
      lower_bound.y = vertex.y if vertex.y < lower_bound.y
      upper_bound.x = vertex.x if vertex.x > upper_bound.x
      upper_bound.y = vertex.y if vertex.y > upper_bound.y

  aabb = new b2AABB()
  aabb.lowerBound.Set(lower_bound.x, lower_bound.y)
  aabb.upperBound.Set(upper_bound.x, upper_bound.y)
  return aabb

visible_edge = (zone, edge) ->
  edge.aabb.TestOverlap(zone.aabb)
