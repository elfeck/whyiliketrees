class window.Polygon

  constructor: (@points, @normalSign = 1) ->
    @normal = Vec.surfaceNormal @points[0], @points[1], @points[2]
    @normal.multScalar @normalSign
    @connections = []

  gfxAddOutline: (color) ->
    n = @points.length
    verts = []
    verts.push(new Vertex([@points[i], color])) for i in [0..n-1]
    prims = []
    prims.push(new Primitive 2, [verts[i], verts[i + 1]]) for i in [0..n-2]
    prims.push(new Primitive 2, [verts[n - 1], verts[0]])
    return prims

  gfxAddFill: (color) ->
    n = @points.length
    verts = []
    verts.push(new Vertex([@points[i], color, @normal])) for i in [0..n-1]
    prims = []
    for i in [0..n-2]
      prims.push(new Primitive 3, [verts[0], verts[i], verts[i + 1]])
    return prims

  updateNormal: ->
    @normal.setTo Vec.surfaceNormal @points[0], @points[1], @points[2]
    @normal.multScalar @normalSign
    return

  rotateAroundLine: (line, angle) ->
    line.rotatePoint p, angle for p in @points
    @updateNormal()
    poly.updateNormal() for poly in conn.polys for conn in @connections
    return

  getOutlineC: (color = new Vec(3, [1.0, 1.0, 1.0])) ->
    col = color.copy()
    verts = []
    n = @points.length
    verts.push(new Vertex([@points[i].copy(), col])) for i in [0..n-1]
    prims = []
    prims.push(new Primitive 2, [verts[i], verts[i + 1]]) for i in [0..n-2]
    prims.push(new Primitive 2, [verts[n - 1], verts[0]])
    return prims

  # only working for convex polygons
  getFillC: (invnormal = false, color = new Vec(3, [1.0, 1.0, 1.0])) ->
    col = color.copy()
    verts = []
    n = @points.length
    normal = Vec.surfaceNormal @points[0], @points[1], @points[2]
    normal.multScalar(-1.0) if invnormal
    verts.push(new Vertex([@points[i].copy(), col, normal])) for i in [0..n-1]
    prims = []
    for i in [0..n-2]
      prims.push(new Primitive 3, [verts[0], verts[i], verts[i + 1]])
    return prims

  @regularFromLine: (line, cdist, n) ->
    angle = 2.0 * Math.PI / n
    vecs = []
    dir = Vec.orthogonalVec(line.dir).normalize()
    for i in [0..n-1]
      vec = line.base.addVecC(dir.multScalarC cdist)
      line.rotatePoint vec, angle * i
      vec.asHom = true
      vecs.push vec
    return new Polygon vecs

  @convexFromLine: (line, cdist, angles, accumulative = true) ->
    vecs = []
    dir = Vec.orthogonalVec(line.dir).normalize()
    accum = 0
    for a in angles
      accum += a if accumulative
      accum = a if not accumulative
      vec = line.base.addVecC(dir.multScalarC cdist)
      line.rotatePoint vec, accum
      vec.asHom = true
      vecs.push vec
    return new Polygon vecs

  @getOutlineConnectionC: (poly1, poly2,
                           color = new Vec 3, [1.0, 1.0, 1.0]) ->
    col = color.copy()
    minInd = @_minDistPairIndices poly1, poly2
    n = poly1.points.length
    prims = []
    for i in [0..n-1]
      vert1 = new Vertex [poly1.points[(i + minInd[0]) %% n], col]
      vert2 = new Vertex [poly2.points[(i + minInd[1]) %% n], col]
      prims.push new Primitive 2, [vert1, vert2]
    return prims

  @getFillConnectionC: (poly1, poly2, color = new Vec 3, [1.0, 1.0, 1.0]) ->
    col = color.copy()
    minInd = @_minDistPairIndices poly1, poly2
    n = poly1.points.length
    prims = []
    for i in [0..n-1]
      vecs = [
        poly1.points[(i + minInd[0]) %% n],
        poly2.points[(i + minInd[1]) %% n],
        poly1.points[(i + 1 + minInd[0]) %% n],
        poly2.points[(i + 1 + minInd[1]) %% n]
      ]
      normal1 = Vec.surfaceNormal vecs[2], vecs[1], vecs[0]
      normal2 = Vec.surfaceNormal vecs[1], vecs[2], vecs[3]
      verts1 = []
      verts2 = []
      verts1.push new Vertex [vecs[i], col, normal1] for i in [0..2]
      verts2.push new Vertex [vecs[i], col, normal2] for i in [1..3]
      prims.push new Primitive 3, verts1
      prims.push new Primitive 3, verts2
    return prims

  #requires same-n-gons
  @connectPTP: (poly1, poly2) ->
    minInd = @_minDistPairIndices poly1, poly2
    p1s = poly1.points
    p2s = poly2.points
    n = p1s.length
    polys = []
    for i in [0..n-1]
      pts1 = [p1s[(minInd[0] + i) %% n], p1s[(minInd[0] + i + 1) %% n]]
      pts2 = [p2s[(minInd[1] + i) %% n], p2s[(minInd[1] + i + 1) %% n]]
      polys.push new Polygon [pts1[0], pts1[1], pts2[0]], 1.0
      polys.push new Polygon [pts1[1], pts2[0], pts2[1]], -1.0
    conn1 =
      connection: poly2
      polys: polys
    conn2 =
      connection: poly1
      polys: polys
    poly1.connections.push conn1
    poly2.connections.push conn2
    return polys

  @connectEquiDist: (poly1, poly2) ->


  @_minDistPairIndices: (poly1, poly2) ->
    n = poly1.points.length
    m = poly2.points.length
    mindist = 1000000
    minInd1 = undefined
    minInd2 = undefined
    for i in [0..n-1]
      for j in [0..m-1]
        if mindist > (d = poly1.points[i].distance(poly2.points[j]))
          mindist = d
          minInd1 = i
          minInd2 = j
    return [minInd1, minInd2]
