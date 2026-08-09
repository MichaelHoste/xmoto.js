# Mark Bayazit's convex decomposition algorithm (http://mnbayazit.com/406/bayazit), ported from
# the TypeScript version in Cocos' engine (MIT, Copyright (c) Xiamen Yaji Software Co., Ltd.):
# https://github.com/cocos/cocos4/blob/v4.0.0/cocos/physics-2d/framework/utils/polygon-separator.ts
# --
# `convex_partition` (Bayazit) itself still assumes a simple polygon: its reflex-vertex candidate
# search is only guaranteed to find a valid split line when the boundary doesn't cross itself. On
# a self-intersecting input it can silently find no candidate at all and fall back to splitting a
# vertex against itself, producing degenerate 1-vertex "polygons" instead of erroring.
# `decompose`, the entry point actually used for the `bayazit` strategy, works around this the way
# the class-level docblock in the original Farseer/cocos port describes but doesn't itself
# implement: it first cuts the (possibly self-intersecting) input into simple loops at each
# crossing (`resolve_self_intersections`), then runs Bayazit's convex_partition on each loop,
# which is then guaranteed simple. That's what makes `bayazit` the one strategy able to produce a
# real (non-degenerate, though not guaranteed minimal) decomposition of xmoto's rare self-
# intersecting blocks instead of bailing out.
# --
# Recursion depth and cost scale with the reflex-vertex/self-intersection count (each step re-
# scans all vertices), so this is a better fit for smaller/self-intersecting shapes than for
# thousands-of-vertex blocky staircases — use quick_decomp/convex_partition for those instead.
class BayazitDecomposition

  # Safety valve for `convex_partition`/`resolve_self_intersections`: on pathological input (e.g.
  # near-collinear "spike" vertices forming a zero-width protrusion) the split search can find a
  # cut that doesn't actually shrink the problem, recursing without ever converging. Kept fairly
  # low (real xmoto self-intersecting blocks seen so far top out at a few dozen vertices, and this
  # strategy isn't meant for large polygons anyway) because each wasted split before the guard
  # fires becomes a separate, likely-overlapping Planck fixture on non-converging input.
  MAX_SPLITS = 200

  # Cyclic vertex access, accepts negative and out-of-range indices.
  # (The upstream `s - (-i % s)` formula is off by one whenever `-i` is an exact multiple of `s`
  # — e.g. at(-1, [x]) resolves to index 1 on a length-1 array — so a plain double-modulo is used
  # instead; it doesn't change results for the non-degenerate inputs the algorithm is meant for.)
  @at: (i, vertices) ->
    n = vertices.length
    vertices[((i % n) + n) % n]

  # Vertices from index `i` to `j` (inclusive), walking forward cyclically.
  @copy: (i, j, vertices) ->
    n  = vertices.length
    j += n while j < i

    (BayazitDecomposition.at(k, vertices) for k in [i..j])

  # Signed area of triangle a-b-c. Positive if c is left of a->b, negative if right, 0 if collinear.
  @area: (a, b, c) ->
    a.x * (b.y - c.y) + b.x * (c.y - a.y) + c.x * (a.y - b.y)

  @left:     (a, b, c) -> BayazitDecomposition.area(a, b, c) >  0
  @left_on:  (a, b, c) -> BayazitDecomposition.area(a, b, c) >= 0
  @right:    (a, b, c) -> BayazitDecomposition.area(a, b, c) <  0
  @right_on: (a, b, c) -> BayazitDecomposition.area(a, b, c) <= 0

  @points_equal: (a, b) -> a.x == b.x && a.y == b.y

  # Precondition: CCW polygon
  @is_reflex: (i, vertices) ->
    at = BayazitDecomposition.at
    BayazitDecomposition.right(at(i - 1, vertices), at(i, vertices), at(i + 1, vertices))

  @square_dist: (a, b) ->
    dx = b.x - a.x
    dy = b.y - a.y
    dx * dx + dy * dy

  # Intersection point of infinite lines p1-p2 and q1-q2 (not segment-bounded). Returns the
  # origin if the lines are parallel, matching the upstream implementation.
  @line_intersect: (p1, p2, q1, q2) ->
    a1  = p2.y - p1.y
    b1  = p1.x - p2.x
    c1  = a1 * p1.x + b1 * p1.y
    a2  = q2.y - q1.y
    b2  = q1.x - q2.x
    c2  = a2 * q1.x + b2 * q1.y
    det = a1 * b2 - a2 * b1

    if Math.abs(det) > 1e-6
      { x: (b2 * c1 - b1 * c2) / det, y: (a1 * c2 - a2 * c1) / det }
    else
      { x: 0, y: 0 }

  # Whether segments a0-a1 and b0-b1 cross (grazing/shared-endpoint touches don't count).
  @segments_intersect: (a0, a1, b0, b1) ->
    return false if BayazitDecomposition.points_equal(a0, b0) || BayazitDecomposition.points_equal(a0, b1) ||
                    BayazitDecomposition.points_equal(a1, b0) || BayazitDecomposition.points_equal(a1, b1)

    return false if Math.max(a0.x, a1.x) < Math.min(b0.x, b1.x) || Math.max(b0.x, b1.x) < Math.min(a0.x, a1.x)
    return false if Math.max(a0.y, a1.y) < Math.min(b0.y, b1.y) || Math.max(b0.y, b1.y) < Math.min(a0.y, a1.y)

    denom = (b1.y - b0.y) * (a1.x - a0.x) - (b1.x - b0.x) * (a1.y - a0.y)
    return false if Math.abs(denom) < 1e-6

    ua = ((b1.x - b0.x) * (a0.y - b0.y) - (b1.y - b0.y) * (a0.x - b0.x)) / denom
    ub = ((a1.x - a0.x) * (a0.y - b0.y) - (a1.y - a0.y) * (a0.x - b0.x)) / denom

    ua > 0 && ua < 1 && ub > 0 && ub < 1

  # Whether the diagonal i-j lies inside both endpoints' cones and doesn't cross any other edge.
  @can_see: (i, j, vertices) ->
    at = BayazitDecomposition.at

    if BayazitDecomposition.is_reflex(i, vertices)
      return false if BayazitDecomposition.left_on(at(i, vertices), at(i - 1, vertices), at(j, vertices)) &&
                      BayazitDecomposition.right_on(at(i, vertices), at(i + 1, vertices), at(j, vertices))
    else
      return false if BayazitDecomposition.right_on(at(i, vertices), at(i + 1, vertices), at(j, vertices)) ||
                      BayazitDecomposition.left_on(at(i, vertices), at(i - 1, vertices), at(j, vertices))

    if BayazitDecomposition.is_reflex(j, vertices)
      return false if BayazitDecomposition.left_on(at(j, vertices), at(j - 1, vertices), at(i, vertices)) &&
                      BayazitDecomposition.right_on(at(j, vertices), at(j + 1, vertices), at(i, vertices))
    else
      return false if BayazitDecomposition.right_on(at(j, vertices), at(j + 1, vertices), at(i, vertices)) ||
                      BayazitDecomposition.left_on(at(j, vertices), at(j - 1, vertices), at(i, vertices))

    for k in [0...vertices.length]
      continue if (k + 1) % vertices.length == i || k == i || (k + 1) % vertices.length == j || k == j
      return false if BayazitDecomposition.segments_intersect(at(i, vertices), at(j, vertices), at(k, vertices), at(k + 1, vertices))

    true

  @signed_area: (vertices) ->
    area = 0
    for vertex, i in vertices
      next = vertices[(i + 1) % vertices.length]
      area += vertex.x * next.y
      area -= vertex.y * next.x
    area / 2

  @is_ccw: (vertices) -> vertices.length < 3 || BayazitDecomposition.signed_area(vertices) > 0

  @force_ccw: (vertices) ->
    vertices.reverse() unless BayazitDecomposition.is_ccw(vertices)
    vertices

  # Splits `vertices` into convex sub-polygons. Precondition: CCW winding (auto-corrected).
  # `splits_left` guards against non-converging input (see MAX_SPLITS): once exhausted, whatever
  # remains is handed back as one (possibly non-convex) piece instead of recursing forever. Planck
  # takes the convex hull of whatever vertices a Polygon shape is given (see the top of this
  # file's caller), so this degrades to a slightly-too-generous hull rather than crashing.
  @convex_partition: (vertices, splits_left = MAX_SPLITS) ->
    if splits_left <= 0
      console.warn("XMoto warning: bayazit decomposition hit its split limit (#{MAX_SPLITS}) on a #{vertices.length}-vertex piece, likely non-converging degenerate geometry. Using it as-is (Planck will convex-hull it).")
      return [vertices]

    at       = BayazitDecomposition.at
    vertices = BayazitDecomposition.force_ccw(vertices.slice())

    for i in [0...vertices.length]
      continue unless BayazitDecomposition.is_reflex(i, vertices)

      lower_dist  = upper_dist  = Infinity
      lower_index = upper_index = 0
      lower_int   = upper_int   = { x: 0, y: 0 }

      for j in [0...vertices.length]
        # if line i-1,i intersects with edge j-1,j
        if BayazitDecomposition.left(at(i - 1, vertices), at(i, vertices), at(j, vertices)) &&
           BayazitDecomposition.right_on(at(i - 1, vertices), at(i, vertices), at(j - 1, vertices))
          p = BayazitDecomposition.line_intersect(at(i - 1, vertices), at(i, vertices), at(j, vertices), at(j - 1, vertices))
          if BayazitDecomposition.right(at(i + 1, vertices), at(i, vertices), p) # make sure it's inside the poly
            d = BayazitDecomposition.square_dist(at(i, vertices), p)
            if d < lower_dist # keep only the closest intersection
              lower_dist  = d
              lower_int   = p
              lower_index = j

        # if line i,i+1 intersects with edge j,j+1
        if BayazitDecomposition.left(at(i + 1, vertices), at(i, vertices), at(j + 1, vertices)) &&
           BayazitDecomposition.right_on(at(i + 1, vertices), at(i, vertices), at(j, vertices))
          p = BayazitDecomposition.line_intersect(at(i + 1, vertices), at(i, vertices), at(j, vertices), at(j + 1, vertices))
          if BayazitDecomposition.left(at(i - 1, vertices), at(i, vertices), p)
            d = BayazitDecomposition.square_dist(at(i, vertices), p)
            if d < upper_dist
              upper_dist  = d
              upper_index = j
              upper_int   = p

      if lower_index == (upper_index + 1) % vertices.length
        # no vertex to connect to: cut through the middle of the two intersection points
        split_point = { x: (lower_int.x + upper_int.x) / 2, y: (lower_int.y + upper_int.y) / 2 }

        lower_poly = BayazitDecomposition.copy(i, upper_index, vertices)
        lower_poly.push(split_point)
        upper_poly = BayazitDecomposition.copy(lower_index, i, vertices)
        upper_poly.push(split_point)
      else
        highest_score = 0
        best_index    = lower_index
        upper_index  += vertices.length while upper_index < lower_index

        for j in [lower_index..upper_index]
          if BayazitDecomposition.can_see(i, j, vertices)
            score = 1 / (BayazitDecomposition.square_dist(at(i, vertices), at(j, vertices)) + 1)

            if BayazitDecomposition.is_reflex(j, vertices)
              if BayazitDecomposition.right_on(at(j - 1, vertices), at(j, vertices), at(i, vertices)) &&
                 BayazitDecomposition.left_on(at(j + 1, vertices), at(j, vertices), at(i, vertices))
                score += 3
              else
                score += 2
            else
              score += 1

            if score > highest_score
              best_index    = j
              highest_score = score

        lower_poly = BayazitDecomposition.copy(i, best_index, vertices)
        upper_poly = BayazitDecomposition.copy(best_index, i, vertices)

      return BayazitDecomposition.convex_partition(lower_poly, splits_left - 1).concat(BayazitDecomposition.convex_partition(upper_poly, splits_left - 1))

    [vertices] # already convex

  # First pair of non-adjacent edges that properly cross (shared-endpoint touches don't count,
  # see `segments_intersect`), or null if `vertices` is already simple.
  @find_self_intersection: (vertices) ->
    n = vertices.length

    for i in [0...n]
      for j in [(i + 1)...n]
        continue if j == i + 1 || (i == 0 && j == n - 1) # edges sharing a vertex aren't a crossing

        a0 = vertices[i]
        a1 = vertices[(i + 1) % n]
        b0 = vertices[j]
        b1 = vertices[(j + 1) % n]

        if BayazitDecomposition.segments_intersect(a0, a1, b0, b1)
          return { i: i, j: j, point: BayazitDecomposition.line_intersect(a0, a1, b0, b1) }

    null

  # Cuts `vertices` into two loops at the crossing between edges i,i+1 and j,j+1 (i < j),
  # inserting the crossing point as a shared vertex of both.
  @split_at_intersection: (vertices, i, j, point) ->
    [
      [point].concat(BayazitDecomposition.copy(i + 1, j, vertices))
      [point].concat(BayazitDecomposition.copy(j + 1, i, vertices))
    ]

  # Recursively cuts a (possibly self-intersecting) polygon at every crossing until every
  # resulting loop is simple. `splits_left` is the same non-convergence guard as in
  # `convex_partition`: on exhaustion, the (still possibly self-intersecting) remainder is handed
  # back as-is rather than recursing forever.
  @resolve_self_intersections: (vertices, splits_left = MAX_SPLITS) ->
    return [vertices] if splits_left <= 0

    crossing = BayazitDecomposition.find_self_intersection(vertices)
    return [vertices] unless crossing

    [loop1, loop2] = BayazitDecomposition.split_at_intersection(vertices, crossing.i, crossing.j, crossing.point)

    BayazitDecomposition.resolve_self_intersections(loop1, splits_left - 1).concat(BayazitDecomposition.resolve_self_intersections(loop2, splits_left - 1))

  # Entry point: splits a (possibly self-intersecting, possibly concave) polygon into convex
  # sub-polygons. Unlike `convex_partition`, this tolerates self-intersecting input.
  @decompose: (vertices) ->
    simple_loops = BayazitDecomposition.resolve_self_intersections(vertices)

    simple_loops.reduce(((all, simple_loop) -> all.concat(BayazitDecomposition.convex_partition(simple_loop))), [])
