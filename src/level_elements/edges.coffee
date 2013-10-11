class Edges

  constructor: (level, blocks) ->
    @level  = level
    @assets = @level.assets
    @theme  = @assets.theme
    @blocks = blocks

    @list   = [] # list of edges

    # Assets
    for block in @blocks
      for vertex in block.vertices
        if vertex.edge
          @assets.effects.push(@theme.edges[vertex.edge].file)

    # Create edges
    for block in @blocks
      for vertex, i in block.vertices
        if vertex.edge
          edge =
            vertex1: vertex
            vertex2: if i == block.vertices.length-1 then block.vertices[0] else block.vertices[i+1]
            block:   block
            texture: vertex.edge
            theme:   @theme.edges[vertex.edge]
          edge.angle = Math2D.angle_between_points(edge.vertex1, edge.vertex2) - Math.PI/2

          @list.push(edge)

  display: (ctx) ->
    # draw back blocks before front blocks
    for edge in @list
      ctx.beginPath()

      ctx.moveTo(edge.block.position.x + edge.vertex1.x, edge.block.position.y + edge.vertex1.y - edge.theme.depth)
      ctx.lineTo(edge.block.position.x + edge.vertex2.x, edge.block.position.y + edge.vertex2.y - edge.theme.depth)
      ctx.lineTo(edge.block.position.x + edge.vertex2.x, edge.block.position.y + edge.vertex2.y)
      ctx.lineTo(edge.block.position.x + edge.vertex1.x, edge.block.position.y + edge.vertex1.y)

      ctx.closePath()

      ctx.save()
      ctx.translate(edge.block.position.x + edge.vertex1.x, edge.block.position.y + edge.vertex1.y) # Always start texture on the left vertex
      ctx.rotate(edge.angle)
      ctx.scale(1.0 / 100, -1.0 / 100)
      ctx.fillStyle = ctx.createPattern(@assets.get(edge.theme.file), 'repeat')
      ctx.fill()
      ctx.restore()

