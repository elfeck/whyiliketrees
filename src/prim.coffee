class window.Line

  constructor: (base, dir, dep = false) ->
    if dep
      @base = base
      @dir = dir
    else
      @base = base.copy()
      @dir = dir.normalizeC()

  pointAtDistanceC: (dist) ->
    return @base.addVecC(@dir.multScalarC(dist))

  shiftBaseC: (dist) ->
    return new Line @pointAtDistanceC(dist), @dir.copy()

  setBase: (newBase) ->
    @base.setTo newBase
    @updateLineSegs()
    return

  setDir: (newDir) ->
    @dir.setTo newDir
    @updateLineSegs()
    return

  getRotationMatrix: (angle, rmat = new Mat(4, 4)) ->
    cc = Math.cos angle
    ss = Math.sin angle
    ic = 1 - cc
    dir = @dir.normalizeC()
    u = dir.data[0]
    v = dir.data[1]
    w = dir.data[2]
    a = @base.data[0]
    b = @base.data[1]
    c = @base.data[2]

    rmat.data[0] = u * u + (v * v + w * w) * cc
    rmat.data[1] = u * v * ic + w * ss
    rmat.data[2] = u * w * ic - v * ss

    rmat.data[4] = u * v * ic - w * ss
    rmat.data[5] = v * v + (u * u + w * w) * cc
    rmat.data[6] = v * w * ic + u * ss

    rmat.data[8] = u * w * ic + v * ss
    rmat.data[9] = v * w * ic - u * ss
    rmat.data[10] = w * w + (u * u + v * v) * cc

    rmat.data[12] = (a * (v * v + w * w) - u * (b * v + c * w)) * ic +
      (b * w - c * v) * ss
    rmat.data[13] = (b * (u * u + w * w) - v * (a * u + c * w)) * ic +
      (c * u - a * w) * ss
    rmat.data[14] = (c * (u * u + v * v) - w * (a * u + b * v)) * ic +
      (a * v - b * u) * ss
    rmat.data[15] = 1.0
    return rmat

  rotatePoint: (point, angle) ->
    cc = Math.cos angle
    ss = Math.sin angle
    ic = 1 - cc
    dir = @dir.normalize()
    u = dir.data[0]
    v = dir.data[1]
    w = dir.data[2]
    a = @base.data[0]
    b = @base.data[1]
    c = @base.data[2]
    x = point.data[0]
    y = point.data[1]
    z = point.data[2]
    point.data[0] =
      (a * (v * v + w * w) - u * (b * v + c * w - u * x - v * y - w * z)) *
      ic + x * cc + (-c * v + b * w - w * y + v * z) * ss
    point.data[1] =
      (b * (u * u + w * w) - v * (a * u + c * w - u * x - v * y - w * z)) *
      ic + y * cc + (c * u - a * w + w * x - u * z) * ss
    point.data[2] =
      (c * (u * u + v * v) - w * (a * u + b * v - u * x - v * y - w * z)) *
      ic + z * cc + (-b * u + a * v - v * x + u * y) * ss
    return point

  rotatePointC: (point, angle) ->
    return @rotatePoint point.copy(), angle

  pointOnLine: (point) ->
    l = undefined
    for i in [0..@dir.dim-1]
      if not isFloatZero @dir.data[i]
        l = (point.data[i] - @base.data[i]) / @dir.data[i]
    return isFloatZero @base.addVecC(@dir.multScalar(l)).distance(point)

  @fromPointsC: (points) ->
    return new Line points[0].copy(), points[1].subVecC(points[0]).normalize()

  # http://paulbourke.net/geometry/pointlineplane/
  # http://paulbourke.net/geometry/pointlineplane/calclineline.cs
  @getIntersectionLine: (l1, l2) ->
    p1 = l1.base
    p3 = l2.base
    p21 = l1.dir
    p43 = l2.dir

    p13 = l1.base.subVecC(l2.base)

    d1343 = p13.x() * p43.x() + p13.y() * p43.y() + p13.z() * p43.z()
    d4321 = p43.x() * p21.x() + p43.y() * p21.y() + p43.z() * p21.z()
    d1321 = p13.x() * p21.x() + p13.y() * p21.y() + p13.z() * p21.z()
    d4343 = p43.x() * p43.x() + p43.y() * p43.y() + p43.z() * p43.z()
    d2121 = p21.x() * p21.x() + p21.y() * p21.y() + p21.z() * p21.z()

    denom = d2121 * d4343 - d4321 * d4321
    numer = d1343 * d4321 - d1321 * d4343
    mua = numer / denom
    mub = (d1343 + d4321 * (mua)) / d4343

    rp1X = (p1.x() + mua * p21.x())
    rp1Y = (p1.y() + mua * p21.y())
    rp1Z = (p1.z() + mua * p21.z())
    rp2X = (p3.x() + mub * p43.x())
    rp2Y = (p3.y() + mub * p43.y())
    rp2Z = (p3.z() + mub * p43.z())

    rp1 = new Vec [rp1X, rp1Y, rp1Z]
    rp2 = new Vec [rp2X, rp2Y, rp2Z]
    line = Line.fromPointsC [rp1, rp2]
    return line

  @onLine: (points) ->
    return true if points.length < 3
    line = Line.fromPointsC points
    for i in [2..points.length-1]
      return false if not line.pointOnLine points[i]
    return true

class window.LineSegment

  constructor: (points, dep = false) ->
    if dep
      @points = points
    else
      @points = []
      @points.push p.copy() for p in points
    # maybe will cause trouble
    p.asHom = true for p in @points

  setTo: (lineSeg) ->
    @points[i].setData lineSeg.points[i].data for i in [0..@points.length-1]

  getLine: ->
    return Line.fromPointsC @points

  length: ->
    return @points[0].distance @points[1]

  gfxAddLineSeg: (color) ->
    verts = [new Vertex([@points[0], color]), new Vertex([@points[1], color])]
    prim = new Primitive 2, verts
    return [prim]

  @connectPoints: (points) ->
    lineSegs = []
    for i in [0..points.length-2]
      lineSegs.push new LineSegment [points[i], points[i + 1]]
    return lineSegs

  @fromLineC: (line, length) ->
    return new LineSegment [line.base.copy(), line.pointAtDistanceC(length)]

class window.Plane

  constructor: (base, unorm, dep = false) ->
    if dep
      @base = base
      @norm = unorm
    else
      @base = base.copy()
      @norm = unorm.normalizeC()

  getPlaneParam: ->
    return -Vec.scalarProd(@norm, @base)

  liesOnPlane: (point) ->
    diff = Vec.scalarProd(point, @norm) + @getPlaneParam()
    return isFloatZero diff

  # only for directional vectors, rotating around 0
  orthogonalInPlane: (vec) ->
    line = new Line(Vec.zeros(3), @norm)
    return line.rotatePointC vec, Math.PI * 0.5

  getOrthogonalPair: ->
    v1 = Vec.orthogonalVec @norm
    v2 = @orthogonalInPlane v1
    return [v1, v2]

  @fromPointsC: (points) ->
    v1 = points[1].subVecC points[0]
    v2 = points[2].subVecC points[0]
    return new Plane points[0].copy(), Vec.crossProd3(v1, v2)

  @fromLineC: (line) ->
    return new Plane line.base.copy(), line.dir.copy().normalize()

class window.Cube

  # always dependend on center
  constructor: (@center, @edgeLen) ->
    @polys = []

  gfxAddFill: (color) ->
    ydir = new Vec [0.0, 1.0, 0.0]
    sideL = @edgeLen / Math.sqrt(2)
    line = new Line @center.addVecC(ydir.multScalarC(-@edgeLen / 2.0)), ydir
    @polys.push Polygon.regularFromLine line, sideL, 4, -1
    @polys.push Polygon.regularFromLine line.shiftBaseC(@edgeLen), sideL, 4
    @polys = @polys.concat Polygon.connectPolygons @polys[0], @polys[1]
    prims = []
    prims = prims.concat p.gfxAddFill color for p in @polys
    return prims

  setCenter: (newCenter) ->
    diff = newCenter.subVecC @center
    @center = newCenter
    @polys[0].translatePoints diff
    @polys[1].translatePoints diff
    return

class window.Circle

  constructor: (baseline, @radius, dep = false) ->
    if dep
      @baseline = baseline
    else
      @baseline = new Line baseline.base, baseline.dir

  isPointWithin: (point) ->
    return @isPointInside(point) || @isPointOn(point)

  isPointInside: (point) ->
    plane = Plane.fromLineC @baseline
    return false if not plane.liesOnPlane point
    return @baseline.base.distance(point) < @radius

  isPointOn: (point) ->
    plane = Plane.fromLineC @baseline
    if not plane.liesOnPlane point
     # console.log "shit"
      return false
    diff = @baseline.base.distance(point) - @radius
    #console.log diff
    return isFloatZero diff

  gfxAddOutline: (numLineSegs, color) ->
    poly = Polygon.regularFromLine @baseline, @radius, numLineSegs
    return poly.gfxAddOutline color

  #http://stackoverflow.com/questions/26901540/arc-in-qgraphicsscene/
  # 26903599#26903599
  @from3PointsC: (points) ->
    a = points[0]
    b = points[1]
    c = points[2]
    bc = c.subVecC(b)
    ac = c.subVecC(a)
    ba = a.subVecC(b)
    plane = Plane.fromPointsC points
    r = Math.abs(bc.length() / (2 * Math.sin(Vec.angleBetween(ac, ba))))
    o1 = plane.orthogonalInPlane(bc)
    o2 = plane.orthogonalInPlane(ba)
    b1 = new Line(b.addVecC(bc.multScalarC(0.5)), o1)
    b2 = new Line(b.addVecC(ba.multScalarC(0.5)), o2)
    base = Line.getIntersectionLine(b1, b2).base
    return new Circle(new Line(base, plane.norm), r)

  @from2PointsC: (points, planeNorm) ->
    if points.length == 2
      a = points[0]
      b = points[1]
      r = 0.5 * a.distance(b)
      center = a.addVecC(b.subVecC(a).multScalar(0.5))
      return new Circle(new Line(center, planeNorm), r)
