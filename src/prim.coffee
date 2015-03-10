class window.Line

  constructor: (@base, @dir) ->
    @_lineSegs = []

  gfxAddLineSeg: (bdist, length, color) ->
    p1 = @pointAtDistanceC(bdist).toHomVecC()
    p2 = @pointAtDistanceC(bdist + length).toHomVecC()
    lineSeg =
      bdist: bdist
      length: length
      points: [p1, p2]
    @_lineSegs.push lineSeg
    verts = [new Vertex([p1, color]), new Vertex([p2, color])]
    prim = new Primitive 2, verts
    return [prim]

  updateLineSegs: () ->
    for ls in @_lineSegs
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

  getLineSegC: (bdist, length, color = new Vec(3, [1.0, 1.0, 1.0])) ->
    col = color.copy()
    verts = [
      new Vertex([@pointAtDistanceC(bdist).toHomVecC(), col]),
      new Vertex([@pointAtDistanceC(bdist + length).toHomVecC(), col])
    ]
    prim = new Primitive 2, verts
    return [prim]

  getRotationMatrix: (angle, rmat = new Mat(4, 4)) ->
    cc = Math.cos angle
    ss = Math.sin angle
    ic = 1 - cc
    u = @dir.data[0]
    v = @dir.data[1]
    w = @dir.data[2]
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
    u = @dir.data[0]
    v = @dir.data[1]
    w = @dir.data[2]
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

  getLineSegsC: (dist1, dist2, color = new Vec(3, [1.0, 1.0, 1.0])) ->
    col = color.copy()
    dir1 = Vec.orthogonalVec(@norm).normalize()
    dir2 = Vec.crossProd3(@norm, dir1).normalize()

    line1 = new Line @base, dir1
    line2 = new Line @base, dir2

    prim1 = line1.toColoredLineSeg -dist1 / 2.0, dist1, col
    prim2 = line2.toColoredLineSeg -dist2 / 2.0, dist2, col

    return [prim1, prim2]

  getFillC: (dist, angle, color = new Vec(3, [1.0, 1.0, 1.0])) ->
    col = color.copy()
    dir1 = Vec.orthogonalVec(@norm).normalize()
    dir2 = Vec.crossProd3(@norm, dir1).normalize()

    dist /= 2.0

    nline = new Line @base, @norm
    rmat = nline.getRotationMatrix angle

    vec1 = @base.addVecC(dir1.multScalarC(dist)).toHomVecC().multMat(rmat)
    vec2 = @base.addVecC(dir2.multScalarC(dist)).toHomVecC().multMat(rmat)
    vec3 = @base.addVecC(dir1.multScalarC(-dist)).toHomVecC().multMat(rmat)
    vec4 = @base.addVecC(dir2.multScalarC(-dist)).toHomVecC().multMat(rmat)

    normal = Vec.surfaceNormal vec1, vec2, vec3

    vert1 = new Vertex([vec1, col, normal])
    vert2 = new Vertex([vec2, col, normal])
    vert3 = new Vertex([vec3, col, normal])
    vert4 = new Vertex([vec4, col, normal])

    prim1 = new Primitive 3, [vert1, vert2, vert3]
    prim2 = new Primitive 3, [vert3, vert4, vert1]

    return [prim1, prim2]

  getPlaneParam: ->
    return -Vec.scalarProd(@norm, @base)

  liesOnPlane: (point) ->
    diff = Vec.scalarProd(point, @norm) + @getPlaneParam()
    return isFloatZero diff

  @fromPoints: (points) ->
    v1 = points[1].subVecC points[0]
    v2 = points[2].subVecC points[0]
    return new Plane points[0].copy(), Vec.crossProd3(v1, v2)


class window.PlatonicSolid

  constructor: ->

  @cubeAroundCenterC: (@center, edgeLength,
                       color = new Vec(3, [1.0, 1.0, 1.0])) ->
    col = color.copy()
    ydir = new Vec 3, [0.0, 1.0, 0.0]
    sideL = edgeLength / Math.sqrt(2)
    line = new Line @center.addVecC(ydir.multScalarC(-edgeLength / 2.0)), ydir
    poly1 = Polygon.regularFromLine line, 4, sideL
    poly2 = Polygon.regularFromLine line.shiftBaseC(edgeLength), 4, sideL
    prims = []
    prims = prims.concat poly1.coloredFillC true, col
    prims = prims.concat poly2.coloredFillC false, col
    prims = prims.concat Polygon.triangleconnectPolysC poly1, poly2, col
    return prims
