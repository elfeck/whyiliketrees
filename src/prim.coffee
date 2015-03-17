class window.Line

  constructor: (@base, @dir) ->
    @lineSegs = []

  gfxAddLineSeg: (bdist, length, color) ->
    p1 = @pointAtDistanceC(bdist).toHomVecC()
    p2 = @pointAtDistanceC(bdist + length).toHomVecC()
    lineSeg =
      bdist: bdist
      length: length
      points: [p1, p2]
    @lineSegs.push lineSeg
    verts = [new Vertex([p1, color]), new Vertex([p2, color])]
    prim = new Primitive 2, verts
    return [prim]

  updateLineSegs: () ->
    for ls in @lineSegs
      ls.points[0].setTo(@base).addVec(@dir.multScalarC(ls.bdist)).toHomVec()
      ls.points[1].setTo(@base).addVec(@dir.multScalarC(ls.bdist + ls.length))
      ls.points[1].toHomVec()
    return

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
    return @rotatePoint point.copy(), point

  @fromPoints: (p1, p2) ->
    return new Line p1.copy(), p2.subVecC(p1).normalize()


class window.Plane

  constructor: (@base, unorm) ->
    @norm = unorm.copy().normalize()

  getPlaneParam: ->
    return -Vec.scalarProd(@norm, @base)

  liesOnPlane: (point) ->
    diff = Vec.scalarProd(point, @norm) + @getPlaneParam()
    return isFloatZero diff

  @fromPoints: (points) ->
    v1 = points[1].subVecC points[0]
    v2 = points[2].subVecC points[0]
    return new Plane points[0].copy(), Vec.crossProd3(v1, v2)


class window.Cube

  constructor: (@center, @edgeLen) ->
    @polys = []

  gfxAddFill: (color) ->
    ydir = new Vec 3, [0.0, 1.0, 0.0]
    sideL = @edgeLen / Math.sqrt(2)
    line = new Line @center.addVecC(ydir.multScalarC(-@edgeLen / 2.0)), ydir
    @polys.push Polygon.regularFromLine line, sideL, 4, -1
    @polys.push Polygon.regularFromLine line.shiftBaseC(@edgeLen), sideL, 4
    @polys = @polys.concat Polygon.pConnectPolygons @polys[0], @polys[1]
    prims = []
    prims = prims.concat p.gfxAddFill color for p in @polys
    return prims

  setCenter: (newCenter) ->
    diff = newCenter.subVecC @center
    @center = newCenter
    @polys[0].translatePoints diff
    @polys[1].translatePoints diff
    return
