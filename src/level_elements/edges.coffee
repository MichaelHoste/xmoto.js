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

  display: (ctx) ->
    # draw back blocks before front blocks
#    for block in @back_list.concat(@front_list)
#      ctx.beginPath()
#
#      for vertex, i in block.vertices
#        if i == 0
#          ctx.moveTo(block.position.x + vertex.x, block.position.y + vertex.y)
#        else
#          ctx.lineTo(block.position.x + vertex.x, block.position.y + vertex.y)
#
#      ctx.closePath()
#
#      ctx.save()
#      ctx.scale(1.0 / @level.scale.x, 1.0 / @level.scale.y)
#      ctx.fillStyle = ctx.createPattern(@assets.get(block.usetexture.id), 'repeat')
#      ctx.fill()
#      ctx.restore()
#
#    @edges.display(ctx)
#
