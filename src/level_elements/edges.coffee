b2Vec2 = Box2D.Common.Math.b2Vec2
b2AABB = Box2D.Collision.b2AABB

class Edges

  constructor: (level) ->
    @level  = level
    @assets = @level.assets
    @theme  = @assets.theme

    @list   = [] # List of edges

  parse: (blocks) ->
    @blocks = blocks

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
          edge.aabb = @compute_aabb(edge)

          @list.push(edge)

  load_assets: ->
    for edge in @list
      @assets.effects.push(edge.theme.file)

  init: ->
    @init_sprites()

  init_sprites: ->
    for edge in @list
      # Create mask
      points = []

      for vertex in edge.vertices
        points.push(new PIXI.Point(vertex.x, -vertex.y))

      mask = new PIXI.Graphics()
      mask.beginFill(0xffffff, 1.0)
      mask.drawPolygon(points)
      @level.camera.translate_container.addChild(mask)

      x = Math.abs(Math.sin(edge.angle) * edge.theme.depth)
      y = Math.abs(Math.tan(edge.angle) * x)

      texture = PIXI.Texture.fromImage(@assets.get_url(edge.theme.file))
      size_x  = edge.aabb.upperBound.x - edge.aabb.lowerBound.x + 2*x
      size_y  = edge.theme.depth# + 2*y

      edge.sprite   = new PIXI.extras.TilingSprite(texture, 4*size_x, size_y)
      edge.sprite.x =  edge.vertex1.absolute_x - x
      edge.sprite.y = -edge.vertex1.absolute_y + y if edge.angle > 0
      edge.sprite.y = -edge.vertex1.absolute_y - y if edge.angle <= 0

      edge.sprite.pivot.x     = 0.5
      edge.sprite.tileScale.x = 1.0 / 100.0
      edge.sprite.tileScale.y = 1.0 / 100.0
      edge.sprite.mask        = mask
      edge.sprite.rotation    = -edge.angle

      @level.camera.translate_container.addChild(edge.sprite)

  # only display edges present on the screen zone
  update: ->
    if !Constants.debug_physics
      for edge in @list
        edge.sprite.visible = @visible(edge)

  compute_aabb: (edge) ->
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

  visible: (edge) ->
    edge.aabb.TestOverlap(@level.camera.aabb)
