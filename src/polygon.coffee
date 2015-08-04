class window.Polygon

  constructor: (@points, @normalSign = 1) ->
    @normal = null
    if @points.length > 2
      @normal = Vec.zeros 3
      @updateNormal()
    @connections = []

  gfxAddOutline: (color) ->
    if @points.length < 2
      dprint "impossible to add outline to point-type polygon"
      return []
    n = @points.length
    verts = []
    verts.push(new Vertex([@points[i], color])) for i in [0..n-1]
    prims = []
    prims.push(new Primitive 2, [verts[i], verts[i + 1]]) for i in [0..n-2]
    prims.push(new Primitive 2, [verts[n - 1], verts[0]])
    return prims

  gfxAddFill: (color) ->
    if @points.length < 3
      dprint "impossible to add fill to point/line-type polygon"
      return []
    n = @points.length
    verts = []
    verts.push(new Vertex([@points[i], color, @normal])) for i in [0..n-1]
    prims = []
    for i in [1..n-2]
      prims.push(new Primitive 3, [verts[0], verts[i], verts[i + 1]])
    return prims

  updateNormal: ->
    return if @points.length < 3
    npts = []
    eps = 0.001
    for p in @points
      break if npts.length == 3
      if npts.length == 0
        npts.push p
        continue
      okay = true
      okay &= eps < p.distance(ex) for ex in npts
      npts.push p if okay
    if npts.length < 3
      dprint "not able to find normal for polygon n>=3"
      @normal.setData [1, 0, 0]
    else
      @normal.setTo Vec.surfaceNormal npts[0], npts[1], npts[2]
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
    c = Vec.zeros 3
    c.addVec p for p in @points
    return c.multScalar(1.0 / @points.length)

  getPlane: ->
    if @points.length < 3
      dprint "attempt to get plane from point/line-type polygon"
      return null
    return Plane.fromPoints @points

  # naive and bad runs in O(n^4). NOT tested for bad cases
  # might not even be the min circle, but just one that contains all pts
  getMinimalOutcircle: ->
    if @points.length < 2
      dprint "attempt to get minimal outcircle from point-type polygon"
      return null
    if @points.length == 2
      return Circle.from2Points @points, @normal
    else
      circle = null
      okay = true
      n = @points.length - 1
      eps = 0.001
      for i in [0..n]
        for j in [0..n]
          for k in [0..n]
            continue if i == j || j == k || i == k
            p1 = @points[i]
            p2 = @points[j]
            p3 = @points[k]
            if p1.distance(p2) < eps || p1.distance(p3) < eps ||
               p2.distance(p3) < eps
              continue
            circle = Circle.from3Points [p1, p2, p3]
            okay = true
            okay &= circle.isPointWithin p for p in @points
            return circle if okay
      # find circle with 2 points only and normal as planenorm
      for i in [0..n]
        for j in [0..n]
          continue if i == j
          p1 = @points[i]
          p2 = @points[j]
          continue if p1.distance(p2) < eps #maybe max dist instead?
          circle = Circle.from2Points [p1, p2], @normal
          okay = true
          okay &= circle.isPointWithin p for p in @points
          return circle if okay
    dprint "No Bounding Circle could be found"
    return undefined

  getMaximalIncircle: ->
    # TODO

  isPointInside: (point) ->
    # TODO

  getCentroidAxis: (length, color) ->
    if @points.length < 3
      dprint "attempt to get centroid axis from p/l-type polygon"
      return null
    return new Line @getCentroid(), @normal.copy()

  getCentroidAxisDebug: (length, color) ->
    if @points.length < 3
      dprint "attempt to get centroid axis from p/l-type polygon"
      return null
    return @getCentroidAxis().getLineSegC 0, length, color

  isRegular: (eps) ->
    distri = new Vec @getCircularAngleDistribution()
    regu = 2 * Math.PI / @points.length
    reguvec = Vec.zeros @points.length
    reguvec.data[i] = regu for i in [0..@points.length-1]
    return reguvec.subVec(distri).length() < eps

  regularizeRel: (perc) ->
    if @points.length < 3
      dprint "attempt to regularize p/l-type polygon"
      return
    regu = 2 * Math.PI / @points.length
    circle = @getMinimalOutcircle()
    distri = @getCircularAngleDistribution()
    # we dont want to move the last vertex at all
    for i in [0..@points.length-2]
      diff = perc * (regu - distri[i])
      console.log i + ": " + diff
      circle.baseline.rotatePoint(@points[i + 1], diff)
      distri[i + 1] -= diff
    @updateConnNormals()
    return

  regularizeAbs: (angle) ->
    if @points.length < 3
      dprint "attempt to regularize p/l-type polygon"
      return
    regu = 2 * Math.PI / @points.length
    circle = @getMinimalOutcircle()
    distri = @getCircularAngleDistribution()
    # we dont want to move the last vertex at all
    for i in [0..@points.length-2]
      total = regu - distri[i]
      a = angle
      a *= -1 if total < 0
      diff = Math.min a, total if total > 0
      diff = Math.max a, total if total <= 0
      circle.baseline.rotatePoint(@points[i + 1], diff)
      distri[i + 1] -= diff
    @updateConnNormals()
    return

  movePointAlongCircleRel: (index, perc) ->
    if @points.length < 3
      dprint "attempt to move point in p/l-type polygon"
      return
    distri = @getCircularAngleDistribution()
    circle = @getMinimalOutcircle()
    angle = distri[index] * perc
    circle.baseline.rotatePoint(@points[index], angle)
    @updateConnNormals()
    return

  movePointAlongCircleAbs: (index, angle) ->
    if @points.length < 3
      dprint "attempt to move point in p/l-type polygon"
      return
    distri = @getCircularAngleDistribution()
    circle = @getMinimalOutcircle()
    angle = Math.min(distri[index], angle)
    circle.baseline.rotatePoint(@points[index], angle)
    @updateConnNormals()
    return

  getCircularAngleDistribution: () ->
    if @points.length < 3
      dprint "attempt to get circular angle distri from p/l-type polygon"
      return null
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

  replicatePoint: (index) ->
    @points.splice(index, 0, @points[index].copy())

  # returns new (!) set of connection polygons
  reconnect: ->
    for c in @connections
      index = -1
      for oc in c.connection.connections
        index = c.connection.connections.indexOf(oc) if this == oc.connection
      # remove to reciprocal connection
      c.connection.connections.splice(index, 1)
    oldConnections = @connections
    @connections = []
    pa = []
    for c in oldConnections
      pa = pa.concat Polygon.connectPolygons(this, c.connection)
    return pa

  toString: ->
    str = ""
    str += "polygon dim=" + @points.length + "\n"
    for i in [0..@points.length-1]
      str += "    v=" + i + ": " + @points[i].data + "  h=" +
        @points[i].asHom + "\n"
    str += "    norm: " + @normal.data
    return str

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

  # minimum distance match points
  @connectPolygons: (p1, p2, normSign = 1.0) ->
    ns = normSign
    return Polygon.connectPolygonPoint p1, p2, ns if p2.points.length < 2
    return Polygon.connectPolygonPoint p2, p1, ns if p1.points.length < 2
    return Polygon.connectPolygonLineSeg p1, p2, ns if p2.points.length < 3
    return Polygon.connectPolygonLineSeg p2, p1, ns if p1.points.length < 3
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
      normSign: normSign
    conn2 =
      connection: poly1
      polys: polys
      normSign: -normSign # might be different
    poly1.connections.push conn1
    poly2.connections.push conn2
    return polys

  # p2 is point
  @connectPolygonPoint: (p1, p2, normSign = 1) ->
    polys = []
    n = p1.points.length
    point = p2.points[0]
    for i in [0..n-1]
      poly = new Polygon [p1.points[i], p1.points[(i+1) %% n], point],
        normSign
      polys.push poly
    conn1 =
      connection: p2
      polys: polys
      normSign: normSign
    conn2 =
      connection: p1
      polys: polys
      normSign: normSign
    p1.connections.push conn1
    p2.connections.push conn2
    return polys

  # p2 is line
  @connectPolygonLineSeg: (p1, p2, normSign = 1) ->
    p1pts = p1.points
    p2pts = p2.points
    polys = []
    outers = []
    ptsm = Polygon.matchPositioningLineSeg p1, p2pts
    #first out of loop
    fstCornerInd = Polygon.minDistToPair p1pts, ptsm, 0, 1
    oldCornerInd = fstCornerInd
    polys.push new Polygon [p1pts[0], p1pts[1], p2pts[fstCornerInd]], normSign
    for i in [1..p1pts.length-1]
      fsti = i
      sndi = (i + 1) %% p1pts.length
      cornerInd = Polygon.minDistToPair p1pts, ptsm, fsti, sndi
      if cornerInd != oldCornerInd
        poly = new Polygon([p2pts[oldCornerInd], p2pts[cornerInd],
          p1pts[fsti]], -normSign)
        polys.push poly
      oldCornerInd = cornerInd
      polys.push new Polygon([p1pts[fsti], p1pts[sndi], p2pts[cornerInd]],
        normSign)
    #wrap around last -> first
    if fstCornerInd != oldCornerInd
      poly = new Polygon([p2pts[oldCornerInd], p2pts[fstCornerInd], p1pts[0]],
        normSign)
      polys.push poly
    conn1 =
      connection: p2
      polys: polys
      normSign: normSign
    conn2 =
      connection: p1
      polys: polys
      normSign: normSign
    p1.connections.push conn1
    p2.connections.push conn2
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
    rangle = Math.acos(Vec.scalarProd poly.normal, ortho.multScalar(1.0))
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
