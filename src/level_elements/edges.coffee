# New Edges implementation:
# -> 1 polygon for the continuous vertices with texture
# -> MeshGeometry with uvs for texture position
# -> 1 GPU call for full edge

class Edges

  constructor: (level, block) ->
    @level  = level
    @block  = block
    @assets = @level.assets

    @polygons = [] # Each polygon is an edge that was created using the contiguous vertices sharing the same edge texture

  parse: ->
    runs = @extract_runs(@block.vertices)

    for run in runs
      theme        = @assets.theme.edge_params(run.texture)
      polygon      = @build_edge_polygon(@block.vertices, run, theme)
      polygon.aabb = @compute_aabb(polygon)
      @polygons.push(polygon)

  # Find maximal runs of consecutive vertices sharing the same edge texture.
  extract_runs: (vertices) ->
    n    = vertices.length
    runs = []
    i    = 0

    while i < n
      if vertices[i].edge
        texture = vertices[i].edge
        j = i + 1
        j += 1 while j < n && vertices[j].edge == texture
        runs.push({ start: i, end: j - 1, texture: texture })
        i = j
      else
        i += 1

    # Wrapping runs (first and last with same texture and continuous positions) are merged.
    if runs.length >= 2
      first = runs[0]
      last  = runs[runs.length - 1]

      if first.start == 0 && last.end == n-1 && first.texture == last.texture
        first.start = last.start
        runs.pop()

    return runs

  # Build the geometry for a single edge polygon run.
  # Collects the surface vertices from run.start through (run.end + 1),
  # then builds a triangle strip projecting downward by theme.depth.
  build_edge_polygon: (vertices, run, theme) ->
    n     = vertices.length
    depth = theme.depth
    scale = theme.scale

    # Collect surface vertices along this edge segment (may wrap)
    surface = []
    span    = ((run.end - run.start + n) % n) + 1 # handles end of run that may be the start vertex!
    i       = run.start
    for k in [0..span]
      v = vertices[i % n]
      surface.push({ x: v.absolute_x, y: v.absolute_y })
      break if i == closing_idx
      i = (i + 1) % n

    surface_count = surface.length

    # Cumulative arc length along the surface → U texture coordinate
    lengths = [0]
    for s in [1...surface_count]
      dx = surface[s].x - surface[s-1].x
      dy = surface[s].y - surface[s-1].y
      lengths.push(lengths[s-1] + Math.sqrt(dx * dx + dy * dy))

    # Build vertex pairs: top row (surface vertices in order),
    # then bottom row (same vertices reversed, offset by -depth)
    poly_vertices = []
    uvs           = []
    for s in [0...surface_count]
      v = surface[s]
      poly_vertices.push({ x: v.x, y: v.y })
      uvs.push(lengths[s] * scale, 0.0)
    for s in [0...surface_count]
      v = surface[surface_count - 1 - s]
      poly_vertices.push({ x: v.x, y: v.y - depth })
      uvs.push(lengths[surface_count - 1 - s] * scale, 0.99)

    # Triangle strip indices (2 triangles per segment)
    indices = []
    for s in [0...surface_count - 1]
      bot_curr = 2 * surface_count - 1 - s
      bot_next = 2 * surface_count - 2 - s
      indices.push(s, s + 1, bot_curr)
      indices.push(s + 1, bot_next, bot_curr)

    return {
      theme:    theme
      vertices: poly_vertices
      uvs:      new Float32Array(uvs)
      indices:  new Uint32Array(indices)
    }

  load_assets: ->
    for polygon in @polygons
      @assets.effects.push(polygon.theme.file)

  init: ->
    @init_sprites()

  init_sprites: ->
    for polygon in @polygons
      # Convert world coords (Y-up) to PIXI coords (Y-down)
      count = polygon.vertices.length
      positions = new Float32Array(count * 2)

      for v, i in polygon.vertices
        positions[i * 2]     = v.x
        positions[i * 2 + 1] = -v.y

      geometry = new PIXI.MeshGeometry({
        positions: positions
        uvs:       polygon.uvs
        indices:   polygon.indices
      })

      texture = PIXI.Texture.from(@assets.get_url(polygon.theme.file))
      texture.source.addressMode = 'repeat'

      polygon.mesh       = new PIXI.Mesh({ geometry: geometry, texture: texture })
      polygon.mesh.label = "Edge (#{@block.graphics.label})"
      @level.layers.layer_for_block(@block).addChild(polygon.mesh)

  # only display edges present on the screen zone
  update: ->
    if !Constants.debug_physics
      block_visible = @block.graphics.visible

      for polygon in @polygons
        polygon.mesh.visible = block_visible && @visible(polygon)

  visible: (polygon) ->
    if @block.position.islayer && @block.position.layerid != undefined
      parallax_layer = @level.layers.list[@block.position.layerid]
      polygon.aabb.TestOverlap(parallax_layer.camera_aabb)
    else
      polygon.aabb.TestOverlap(@level.camera.aabb)

  compute_aabb: (polygon) ->
    x_positions = polygon.vertices.map((v) -> v.x)
    y_positions = polygon.vertices.map((v) -> v.y)

    aabb = new Box2D.Collision.b2AABB()
    aabb.lowerBound.Set(Math.min.apply(null, x_positions), Math.min.apply(null, y_positions))
    aabb.upperBound.Set(Math.max.apply(null, x_positions), Math.max.apply(null, y_positions))

    return aabb
