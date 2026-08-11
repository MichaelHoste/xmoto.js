class Polygon

  SPLIT_MAX_VERTICES      = 12     # Based on Planck Settings.MaxPolygonVertices value
  DUPLICATE_MAX_DISTANCE  = 0.0025 # based on our Planck Settings.linearSlop value
  COLLINEAR_MAX_ANGLE_RAD = 0.01   # ~0.5°

  # Strategies available for `decompose_to_convex` (see comment there for tradeoffs)
  DECOMPOSE_STRATEGIES =
    POLY_QUICK_DECOMP: 'poly-quick-decomp' # poly-decomp's quickDecomp (Mark Penner): fast, non-optimal number of polygons.
    POLY_DECOMP:       'poly-decomp'       # poly-decomp's decomp (Mark Penner): optimal number of polygons. O(N^4) so exponentially slow for big polygons.
    POLY_PARTITION:    'poly-partition'    # poly-partition-js's convexPartition (Hertel-Mehlhorn): near-optimal pieces, O(n log n).
    BAYAZIT:           'bayazit'           # Mark Bayazit's algorithm (ported from Cocos using AI): only strategy that tolerates self-intersecting polygons, but the results may vary and it can create degenerate polygons (polygons with < 3 vertices).

  DEFAULT_DECOMPOSE_STRATEGY = 'poly-quick-decomp'

  # array of {x, y:}
  constructor: (vertices) ->
    @vertices = Array.from(vertices) # Make copy

    if @vertices.length < 3
      console.error("XMoto error: Polygon created with less than 3 segments, it should never happen.")

  length: ->
    @vertices.length

  # Whether all turns go the same way (all left or all right). Near-zero cross products
  # (collinear-ish turns) don't break convexity on their own.
  # cf. https://www.geeksforgeeks.org/dsa/check-if-given-polygon-is-a-convex-polygon-or-not
  is_convex: (epsilon = 1e-9) ->
    return false if @vertices.length < 3

    sign = 0

    for i in [0...@vertices.length]
      a = @vertices[i]
      b = @vertices[(i + 1) % @vertices.length]
      c = @vertices[(i + 2) % @vertices.length]

      cross = (b.x - a.x) * (c.y - b.y) - (b.y - a.y) * (c.x - b.x)
      continue if Math.abs(cross) < epsilon

      current_sign = if cross > 0 then 1 else -1

      if sign == 0
        sign = current_sign
      else if current_sign != sign
        return false

    true

  is_concave: (epsilon = 1e-9) ->
    !@is_convex(epsilon)

  # Simple polygons don't intersect themselves
  is_simple: ->
    pairs = @vertices.map((vertex) -> [vertex.x, vertex.y])
    decomp.isSimple(pairs)

  self_intersect: ->
    !@is_simple()

  # Detect if polygon has duplicate vertices
  has_duplicate_vertices: (distance = DUPLICATE_MAX_DISTANCE) ->
    pairs = @vertices.map((vertex) -> [vertex.x, vertex.y])
    decomp.removeDuplicatePoints(pairs, distance)
    @vertices.length != pairs.length

  # Optimize polygon:
  # * Remove consecutive vertices that are too close (or identical)
  # * Remove collinear vertices that brings nothing to the polygon
  # * Also check if vertices intersect themselves
  optimize: ->
    @remove_duplicate_vertices
    @remove_collinear_vertices

  # Remove consecutive vertices that are too close (or identical)
  remove_duplicate_vertices: (distance = DUPLICATE_MAX_DISTANCE) ->
    pairs = @vertices.map((vertex) -> [vertex.x, vertex.y])

    decomp.removeDuplicatePoints(pairs, distance)

    if @vertices.length == pairs.length
      # Do nothing if the number if the same
    else if pair.length >= 3
      console.warn("XMoto warning: #{@vertices.length - pairs.length} duplicate vertices have been removed.")
      @vertices = pairs.map((pair) -> { x: pair[0], y: pair[1] })
    else
      # We ignore degenerated polygons
      console.error("XMoto error: polygon degenerated from #{@vertices.length} to #{pairs.length} vertex(es) after removing duplicates, and was ignored.")
      @vertices = []

  # Removes collinear vertices from the polygon. This means that if three vertices are placed along the same line, the middle one will be removed.
  # The angle_rad determines whether the points are collinear or not.
  remove_collinear_vertices: (angle_rad = COLLINEAR_MAX_ANGLE_RAD) ->
    pairs = @vertices.map((vertex) -> [vertex.x, vertex.y])

    decomp.removeCollinearPoints(pairs, angle_rad)

    if @vertices.length == pairs.length
      # Do nothing if the number if the same
    else if pairs.length >= 3
      console.warn("XMoto warning: #{@vertices.length - pairs.length} collinear vertices have been removed.")
      @vertices = pairs.map((pair) -> { x: pair[0], y: pair[1] })
    else
      console.error("XMoto error: polygon degenerated from #{@vertices.length} to #{pairs.length} vertex(es) after removing collinear, and was ignored.")
      @vertices = []

  # Splits the (convex) polygon into smaller convex polygons with a maximal number of vertices, using balanced recursive diagonal splitting.
  # return an array of new Polygon objects,
  split: (max_vertices = SPLIT_MAX_VERTICES) ->
    return [new Polygon(@vertices)] if @vertices.length <= max_vertices

    n   = @vertices.length
    mid = Math.floor(n / 2)

    # Diagonal from vertex 0 to vertex `mid` splits the convex polygon
    # into two convex halves, sharing that edge.
    left  = @vertices.slice(0, mid + 1)
    right = @vertices.slice(mid).concat([@vertices[0]])

    left_polygons  = new Polygon(left).split(max_vertices)
    right_polygons = new Polygon(right).split(max_vertices)

    left_polygons.concat(right_polygons)

  # Decompose a (convex or concave) polygon into convex sub-polygons using multiple strategies (cf. DECOMPOSE_STRATEGIES)
  # Returns the original polygon if the polygon intersect with itself with a strategy that doesn't support it
  decompose: (strategy = DEFAULT_DECOMPOSE_STRATEGY) ->
    if !_.values(DECOMPOSE_STRATEGIES).includes(strategy)
      throw new Error("XMoto error: unknown Polygon#decompose strategy '#{strategy}'") # hard failure!

    # Force Bayazit strategy if self-intersecting polygon (the only one that supports it)
    if @self_intersect() && strategy != DECOMPOSE_STRATEGIES.BAYAZIT
      console.warn("XMoto warning: polygon intersects itself, can't be split with \"#{strategy}\" strategy into convex polygons.")
      return [new Polygon(@vertices)]

    polygons = switch strategy
      when DECOMPOSE_STRATEGIES.POLY_QUICK_DECOMP
        @_poly_quick_decomp_decomposition()
      when DECOMPOSE_STRATEGIES.POLY_DECOMP
        @_poly_decomp_decomposition()
      when DECOMPOSE_STRATEGIES.POLY_PARTITION
        @_poly_partition_decomposition()
      when DECOMPOSE_STRATEGIES.BAYAZIT
        @_bayazit_decomposition()

    # Sanity-check the decomposition output.
    for polygon in polygons
      if polygon.is_concave()
        console.error("XMoto error: decompose (#{strategy}) produced a concave polygon.")
      if polygon.self_intersect()
        console.error("XMoto error: decompose (#{strategy}) produced a self-intersecting polygon.")
      if polygon.has_duplicate_vertices() # DUPLICATE_MAX_DISTANCE/2 ?
        console.warn("XMoto warning: decompose (#{strategy}) produced a polygon with duplicate vertices.")

    polygons

  _poly_quick_decomp_decomposition: ->
    # This algo need CCW vertices
    pairs = @vertices.map((vertex) -> [vertex.x, vertex.y])
    decomp.makeCCW(pairs)

    max_level = Math.max(pairs.length, 100) # Increase max level to be able to finish decomposition without error for big polygons
    polygons  = decomp.quickDecomp(pairs, undefined, undefined, undefined, undefined, max_level)

    polygons.map((vertices) ->
      vertices = vertices.map((vertex) -> { x: vertex[0], y: vertex[1] })
      new Polygon(vertices)
    )

  _poly_decomp_decomposition: ->
    # This algo need CCW vertices
    pairs = @vertices.map((vertex) -> [vertex.x, vertex.y])
    decomp.makeCCW(pairs)

    polygons = decomp.decomp(pairs)

    polygons.map((vertices) ->
      vertices = vertices.map((vertex) -> { x: vertex[0], y: vertex[1] })
      new Polygon(vertices)
    )

  _poly_partition_decomposition: ->
    # This algo need CCW vertices
    pairs = @vertices.map((vertex) -> [vertex.x, vertex.y])
    decomp.makeCCW(pairs)
    @vertices = pairs.map((pair) -> { x: pair[0], y: pair[1] })

    polygons = PolyPartition.convexPartition(@vertices, true)
    polygons.map((vertices) -> new Polygon(vertices))

  _bayazit_decomposition: ->
    # This algo *don't* need CCW vertices
    polygons = BayazitDecomposition.decompose(@vertices)
    polygons.map((vertices) -> new Polygon(vertices))
