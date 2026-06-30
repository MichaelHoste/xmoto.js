# Old "naïve" Edge method. Drop-in replacement but:
#  -> 1 rectangle every 2 vertices + depth
#  -> Texture with same angle as rectangle
#  -> Visually quite nice but not the native XMoto implementation, and too many GPU calls?

class EdgesWithAngle

  constructor: (level, block) ->
    @level  = level
    @block  = block
    @assets = @level.assets

    @list = [] # List of edges

  parse: ->
    for vertex, i in @block.vertices
      if vertex.edge
        edge =
          vertex1: vertex
          vertex2: if i == @block.vertices.length-1 then @block.vertices[0] else @block.vertices[i+1]
          block:   @block
          texture: vertex.edge
          theme:   @assets.theme.edge_params(vertex.edge)

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
    @init_graphics()

  init_graphics: ->
    for edge in @list
      # Build polygon in PIXI coordinates (y inverted)
      points = edge.vertices.map((vertex) ->
        new PIXI.Point(vertex.x, -vertex.y)
      )

      # Load edge texture
      texture = PIXI.Texture.from(@assets.get_url(edge.theme.file))

      # Matrix maps world coords → texture UV, pivoting around top-left corner.
      matrix = new PIXI.Matrix()
      matrix.scale(1.0 / 110.0, 1.0 / 110.0 * edge.theme.scale * edge.theme.depth) # reverse engineering to get nice visual values
      matrix.rotate(-edge.angle)
      matrix.translate(edge.vertex1.absolute_x, -edge.vertex1.absolute_y)

      # Create graphics with texture and matrix
      edge.graphics = new PIXI.Graphics()
      edge.graphics.poly(points)
      edge.graphics.fill({
        texture:      texture,
        matrix:       matrix,
        color:        0xffffff,
        alpha:        1.0,
        textureSpace: 'global'
      })

      @level.layers.static_level.addChild(edge.graphics)

  # only display edges present on the screen zone
  update: ->
    if !Constants.debug_physics
      block_visible = @block.graphics.visible

      for edge in @list
        edge.graphics.visible = block_visible && @visible(edge) # don't test aabb if block not visible

  compute_aabb: (edge) ->
    x_positions = edge.vertices.map((v) -> v.x)
    y_positions = edge.vertices.map((v) -> v.y)

    aabb = new Box2D.Collision.b2AABB()
    aabb.lowerBound.Set(Math.min.apply(null, x_positions), Math.min.apply(null, y_positions))
    aabb.upperBound.Set(Math.max.apply(null, x_positions), Math.max.apply(null, y_positions))

    return aabb

  visible: (edge) ->
    edge.aabb.TestOverlap(@level.camera.aabb)
