class Edges

  constructor: (level, block) ->
    @level  = level
    @block  = block
    @assets = @level.assets
    @theme  = @assets.theme

    @list   = [] # List of edges

  parse: ->
    for vertex, i in @block.vertices
      if vertex.edge
        edge =
          vertex1: vertex
          vertex2: if i == @block.vertices.length-1 then @block.vertices[0] else @block.vertices[i+1]
          block:   @block
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
      # Build polygon in PIXI coordinates (y inverted)
      points = edge.vertices.map((vertex) ->
        new PIXI.Point(vertex.x, -vertex.y)
      )

      # Load edge texture
      texture = PIXI.Texture.from(@assets.get_url(edge.theme.file))

      # Matrix maps world coords → texture UV, pivoting around top-left corner.
      matrix = new PIXI.Matrix()
      matrix.scale(1.0 / 100.0, 1.0 / 100.0)
      matrix.rotate(-edge.angle)
      matrix.translate(edge.vertex1.absolute_x, -edge.vertex1.absolute_y)

      # Create graphics with texture and matrix
      edge.graphics = new PIXI.Graphics()
      edge.graphics.beginTextureFill({
        texture: texture,
        matrix:  matrix,
        color:   0xffffff,
        alpha:   1.0
      })
      edge.graphics.drawPolygon(points)
      edge.graphics.endFill()

      @level.camera.neutral_z_container.addChild(edge.graphics)

  # only display edges present on the screen zone
  update: ->
    if !Constants.debug_physics
      block_visible = @block.sprite.visible

      for edge in @list
        edge.graphics.visible = block_visible && @visible(edge) # don't test aabb if block not visible

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

    aabb = new Box2D.Collision.b2AABB()
    aabb.lowerBound.Set(lower_bound.x, lower_bound.y)
    aabb.upperBound.Set(upper_bound.x, upper_bound.y)
    return aabb

  visible: (edge) ->
    edge.aabb.TestOverlap(@level.camera.aabb)
