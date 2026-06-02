class Edges

  constructor: (level, block) ->
    @level  = level
    @block  = block
    @assets = @level.assets

    @list = [] # List of edges (contiguous vertices sharing the same edge texture)

  parse: ->
    vertices = @block.vertices
    n        = vertices.length

    # Collect runs of consecutive vertices with the same edge texture
    runs = []
    i    = 0

    while i < n
      if vertices[i].edge
        texture = vertices[i].edge

        j =  i + 1
        j += 1 while j < n && vertices[j].edge == texture

        runs.push({ start: i, end: j - 1, texture: texture })

        i = j
      else
        i += 1

    # Handle wrapping: if first and last runs share the same texture, merge them
    if runs.length > 1 && runs[0].texture == runs[runs.length - 1].texture
      runs[0].start = runs[runs.length - 1].start
      runs.pop()

    # Build one polygon per run
    for run in runs
      start_idx          = run.start
      closing_idx        = (run.end + 1) % vertices.length  # first vertex after the run (may wrap)
      theme              = @assets.theme.edge_params(run.texture)
      polygon            = @build_polygon(vertices, start_idx, closing_idx, run.texture, theme)
      polygon.aabb       = @compute_aabb(polygon)
      @list.push(polygon)

  build_polygon: (vertices, start_idx, closing_idx, texture, theme) ->
    n = vertices.length

    # Collect surface vertices from start_idx to closing_idx (inclusive, may wrap)
    surface = []
    i = start_idx
    loop
      surface.push({ x: vertices[i].absolute_x, y: vertices[i].absolute_y })
      break if i == closing_idx
      i = (i + 1) % n

    N = surface.length  # number of surface vertices (K+1 where K = polygon segment count)

    # Compute cumulative arc lengths along the surface for U coordinates
    total_length = 0
    lengths = [0]
    for s in [1...N]
      dx = surface[s].x - surface[s-1].x
      dy = surface[s].y - surface[s-1].y
      total_length += Math.sqrt(dx * dx + dy * dy)
      lengths.push(total_length)

    # UV: U along the edge (tiles via repeat), V across the depth (0→1).
    vertices = []
    uvs      = []
    depth    = theme.depth
    scale    = theme.scale

    for s in [0...N]
      v = surface[s]
      vertices.push({ x: v.x, y: v.y })
      uvs.push(lengths[s] * scale, 0.0)

    for s in [0...N]
      v = surface[N - 1 - s]
      vertices.push({ x: v.x, y: v.y - depth })
      uvs.push(lengths[N - 1 - s] * scale, 0.99)

    # Build triangle indices for the strip
    indices = []
    for s in [0...N - 1]
      o_i   = 2 * N - 1 - s
      o_ip1 = 2 * N - 2 - s
      indices.push(s, s + 1, o_i)
      indices.push(s + 1, o_ip1, o_i)

    return {
      texture:  texture
      theme:    theme
      vertices: vertices
      uvs:      new Float32Array(uvs)
      indices:  new Uint32Array(indices)
    }

  load_assets: ->
    for polygon in @list
      @assets.effects.push(polygon.theme.file)

  init: ->
    @init_sprites()

  init_sprites: ->
    for polygon in @list
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

      polygon.mesh = new PIXI.Mesh({ geometry: geometry, texture: texture })
      @level.camera.neutral_z_container.addChild(polygon.mesh)

  # only display edges present on the screen zone
  update: ->
    if !Constants.debug_physics
      block_visible = @block.graphics.visible

      for chain in @list
        chain.mesh.visible = block_visible && @visible(chain)

  compute_aabb: (chain) ->
    x_positions = chain.vertices.map((v) -> v.x)
    y_positions = chain.vertices.map((v) -> v.y)

    aabb = new Box2D.Collision.b2AABB()
    aabb.lowerBound.Set(Math.min.apply(null, x_positions), Math.min.apply(null, y_positions))
    aabb.upperBound.Set(Math.max.apply(null, x_positions), Math.max.apply(null, y_positions))

    return aabb

  visible: (chain) ->
    chain.aabb.TestOverlap(@level.camera.aabb)
