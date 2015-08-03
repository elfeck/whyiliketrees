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
    for i in [1..n-2]
      prims.push(new Primitive 3, [verts[0], verts[i], verts[i + 1]])
    return prims

  updateNormal: ->
    @normal.setTo Vec.surfaceNormal @points[0], @points[1], @points[2]
    @normal.multScalar @normalSign
    return

  updateConnNormals: ->
    poly.updateNormal() for poly in conn.polys for conn in @connections
    return

  rotateAroundLine: (line, angle) ->
    line.rotatePoint p, angle for p in @points
    @updateNormal()
    @updateConnNormals()
    return

  translatePoints: (dir) ->
    p.addVec dir for p in @points
    return

  getCentroid: ->
    c = new Vec 3
    c.addVec p for p in @points
    return c.multScalar(1.0 / @points.length)

  getPlane: ->
    return Plane.fromPoints @points

  # naive and bad runs in O(n^4). NOT tested for bad cases
  # might not even be the min circle, but just one that contains all pts
  getMinimalOutcircle: ->
    circle = null
    allWithin = true
    for p1 in @points
      for p2 in @points
        for p3 in @points
          continue if p1 == p2 || p2 == p3 || p1 == p3
          circle = Circle.fromPoints [p1, p2, p3]
          allWithin = true
          allWithin &= circle.isPointWithin p for p in @points
          return circle if allWithin
    dprint "No Bounding Circle could be found"
    return undefined

  getMaximalIncircle: ->
    # TODO

  isPointInside: (point) ->
    # TODO

  getCentroidAxis: (length, color) ->
    return new Line @getCentroid(), @normal.copy()

  getCentroidAxisDebug: (length, color) ->
    return @getCentroidAxis().getLineSegC 0, length, color

  isRegular: (eps) ->
    distri = new Vec @points.length, @getCircularAngleDistribution()
    regu = 2 * Math.PI / @points.length
    reguvec = new Vec @points.length
    reguvec.data[i] = regu for i in [0..@points.length-1]
    return reguvec.subVec(distri).length() < eps

  regularizeRel: (perc) ->
    regu = 2 * Math.PI / @points.length
    console.log "regu: " + regu
    circle = @getMinimalOutcircle()
    distri = @getCircularAngleDistribution()
    # we dont want to move the last vertex at all
    for i in [0..@points.length-2]
      diff = perc * (regu - distri[i])
      circle.baseline.rotatePoint(@points[i + 1], diff)
      distri[i + 1] -= diff
    @updateConnNormals()
    return

  regularizeAbs: (angle) ->
    regu = 2 * Math.PI / @points.length
    circle = @getMinimalOutcircle()
    distri = @getCircularAngleDistribution()
    # we dont want to move the last vertex at all
    for i in [0..@points.length-2]
      diff = Math.min angle, (regu - distri[i])
      circle.baseline.rotatePoint(@points[i + 1], diff)
      distri[i + 1] -= diff
    @updateConnNormals()
    return

  movePointAlongCircleRel: (index, perc) ->
    distri = @getCircularAngleDistribution()
    circle = @getMinimalOutcircle()
    angle = distri[index] * perc
    circle.baseline.rotatePoint(@points[index], angle)
    @updateConnNormals()
    return

  movePointAlongCircleAbs: (index, angle) ->
    distri = @getCircularAngleDistribution()
    circle = @getMinimalOutcircle()
    angle = Math.min(distri[index], angle)
    circle.baseline.rotatePoint(@points[index], angle)
    @updateConnNormals()
    return

  getCircularAngleDistribution: () ->
    allOn = true
    circle = @getMinimalOutcircle()
    allWithin = true
    allWithin &= circle.isPointOn p for p in @points
    if not allWithin
      dprint "Unable to get angle distri. not all points ON circle outline"
      return null
    distri = []
    for i in [0..@points.length-1]
      ac = circle.baseline.base.subVecC(@points[i])
      bc = circle.baseline.base.subVecC(@points[(i + 1) %% @points.length])
      distri.push(Vec.angleBetween(ac, bc))
    return distri

  getAngles: () ->
    angles = []
    for i in [0..@points.length-1]
      ba = @points[(i + 1) %% @points.length].subVecC @points[i]
      bc = @points[(i + 1) %% @points.length].subVecC(
        @points[(i + 2) %% @points.length])
      angles.push(Vec.angleBetween(ba, bc))
    return angles

  @regularFromLine: (line, cdist, n, normSign = 1.0) ->
    angle = 2.0 * Math.PI / n
    vecs = []
    dir = Vec.orthogonalVec(line.dir).normalize()
    for i in [0..n-1]
      vec = line.base.addVecC(dir.multScalarC cdist)
      line.rotatePoint vec, angle * i
      vec.asHom = true
      vecs.push vec
    return new Polygon vecs, normSign

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
    minInd = @minDistPairIndices poly1, poly2
    n = poly1.points.length
    prims = []
    for i in [0..n-1]
      vert1 = new Vertex [poly1.points[(i + minInd[0]) %% n], col]
      vert2 = new Vertex [poly2.points[(i + minInd[1]) %% n], col]
      prims.push new Primitive 2, [vert1, vert2]
    return prims

  @getFillConnectionC: (poly1, poly2, color = new Vec 3, [1.0, 1.0, 1.0]) ->
    col = color.copy()
    minInd = @minDistPairIndices poly1, poly2
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

  @connectPoint: (pol, point) ->
    polys = []
    n = pol.points.length
    for i in [0..n-1]
      poly = new Polygon [pol.points[i], pol.points[(i+1) %% n], point], -1.0
      polys.push poly
    conn =
      connection: point
      polys: polys
    pol.connections.push conn
    return polys

  @connectLineSeg: (pol, pts) ->
    polpts = pol.points
    polys = []
    outers = []
    ptsm = Polygon.matchPositioningLineSeg pol, pts
    #first out of loop
    fstCornerInd = Polygon.minDistToPair polpts, ptsm, 0, 1
    oldCornerInd = fstCornerInd
    polys.push new Polygon [polpts[0], polpts[1], pts[fstCornerInd]], -1
    for i in [1..polpts.length-1]
      fsti = i
      sndi = (i + 1) %% polpts.length
      cornerInd = Polygon.minDistToPair polpts, ptsm, fsti, sndi
      if cornerInd != oldCornerInd
        poly = new Polygon([pts[oldCornerInd], pts[cornerInd], polpts[fsti]])
        polys.push poly
      oldCornerInd = cornerInd
      polys.push new Polygon [polpts[fsti], polpts[sndi], pts[cornerInd]], -1
    #wrap around last -> first
    if fstCornerInd != oldCornerInd
      poly = new Polygon([pts[oldCornerInd], pts[fstCornerInd], polpts[0]])
      polys.push poly
    conn =
      connection: pts
      polys: polys
    pol.connections.push conn
    return polys

  # minimum distance match points
  @pConnectPolygons: (p1, p2, normSign = 1.0) ->
    if p1.points.length <= p2.points.length
      poly1 = p1 # poly1 = smaller n = inner
      poly2 = p2 # poly2 = bigger n = outer
    else
      poly1 = p2
      poly2 = p1
    p1s = poly1.points
    p2s = poly2.points
    #move them on top of each other
    p2sm = Polygon.matchPositioningPoly(poly1, poly2).points
    polys = []
    outers = []
    outers.push [] for i in [0..p1s.length-1]
    for i in [0..p1s.length-1]
      # inner partitions outer in outers[inner] = [lowerInd, upperInd]
      fsti = i
      sndi = (i + 1) %% p1s.length
      cornerInd = Polygon.minDistToPair p1s, p2sm, fsti, sndi
      outers[fsti].push cornerInd
      outers[sndi].push cornerInd
      polys.push new Polygon [p1s[fsti], p1s[sndi], p2s[cornerInd]], normSign
    # switch only first
    k = outers[0][0]
    outers[0][0] = outers[0][1]
    outers[0][1] = k
    for i in [0..p1s.length-1]
      bases = Polygon.getBases outers, i, p2s.length
      continue if bases.length == 0 # needed if n = n
      for j in [0..bases.length-2]
        poly = new Polygon [p2s[bases[j]], p2s[bases[j+1]], p1s[i]], -normSign
        polys.push poly
    conn1 =
      connection: poly2
      polys: polys
    conn2 =
      connection: poly1
      polys: polys
    poly1.connections.push conn1
    poly2.connections.push conn2
    return polys

  @getBases: (outers, i, n) ->
    span = outers[i]
    result = []
    dist = (span[1] + n - span[0]) %% n
    return [] if dist == 0
    for i in [0..dist]
      result.push (span[0] + i) %% n
    return result

  @minDistToPair: (base, corner, ind1, ind2, used = []) ->
    minInd = undefined
    mindist = 1000000
    for i in [0..corner.length-1]
      dist = base[ind1].distance(corner[i])
      dist += base[ind2].distance(corner[i])
      if mindist > dist and used.indexOf(i) < 0
        mindist = dist
        minInd = i
    return minInd

  @matchPositioningLineSeg: (poly, pts) ->
    centr = pts[0].addVecC(pts[1]).multScalar(0.5)
    centDiff = poly.getCentroid().subVec centr
    p1t = pts[0].addVecC centDiff
    p2t = pts[1].addVecC centDiff
    ortho = Vec.orthogonalVec p1t, p2t
    if isFloatZero(Math.abs(Vec.scalarProd(poly.normal, ortho)) - 1)
      return [p1t, p2t]
    axis = Vec.crossProd3(poly.normal, ortho).normalize()
    centr = p1t.addVecC(p2t).multScalar(0.5)
    rline = new Line centr, axis
    rangle = Math.acos(Vec.scalarProd poly.normal, ortho.multScalar(-1.0))
    rline.rotatePoint p1t, rangle
    rline.rotatePoint p2t, rangle
    return [p1t, p2t]

  @matchPositioningPoly: (poly1, poly2) ->
    newpoints = []
    newpoints.push p.copy() for p in poly2.points
    newPoly = new Polygon newpoints, poly2.normalSign
    centDiff = poly1.getCentroid().subVec newPoly.getCentroid()
    newPoly.translatePoints centDiff
    if isFloatZero(Math.abs(Vec.scalarProd(poly1.normal, newPoly.normal)) - 1)
      return newPoly
    axis = Vec.crossProd3(poly1.normal, newPoly.normal).normalize()
    rline = new Line newPoly.getCentroid(), axis
    # might need multScalarC -1.0 for 180 deg flip fix now 1.0
    rangle = Math.acos(
      Vec.scalarProd poly1.normal, newPoly.normal.multScalarC(1.0))
    newPoly.rotateAroundLine rline, rangle
    return newPoly
