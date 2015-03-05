class window.Line

  constructor: (@base, @dir) ->

  pointAtDistance: (dist) ->
    return @base.addVecC(@dir.multScalarC(dist))

  shiftBaseC: (dist) ->
    return new Line @pointAtDistance(dist), @dir.copy()

  coloredLineSeg: (bdist, length, color = new Vec(3, [1.0, 1.0, 1.0])) ->
    verts = [
      new Vertex([@pointAtDistance(bdist).toHomVecC(), color]),
      new Vertex([@pointAtDistance(bdist + length).toHomVecC(), color])
    ]
    prim = new Primitive 2, verts
    return [prim]

  getRotationMatrix: (angle, rmat = new Mat(4, 4)) ->
    cc = Math.cos angle
    ss = Math.sin angle
    ic = 1 - cc
    u = @dir.data()[0]
    v = @dir.data()[1]
    w = @dir.data()[2]
    a = @base.data()[0]
    b = @base.data()[1]
    c = @base.data()[2]

    #if rmat.data()[0] == 0
      #console.log [a, b, c]

    rmat.data()[0] = u * u + (v * v + w * w) * cc
    rmat.data()[1] = u * v * ic + w * ss
    rmat.data()[2] = u * w * ic - v * ss

    rmat.data()[4] = u * v * ic - w * ss
    rmat.data()[5] = v * v + (u * u + w * w) * cc
    rmat.data()[6] = v * w * ic + u * ss

    rmat.data()[8] = u * w * ic + v * ss
    rmat.data()[9] = v * w * ic - u * ss
    rmat.data()[10] = w * w + (u * u + v * v) * cc

    rmat.data()[12] = (a * (v * v + w * w) - u * (b * v + c * w)) * ic +
      (b * w - c * v) * ss
    rmat.data()[13] = (b * (u * u + w * w) - v * (a * u + c * w)) * ic +
      (c * u - a * w) * ss
    rmat.data()[14] = (c * (u * u + v * v) - w * (a * u + b * v)) * ic +
      (a * v - b * u) * ss
    rmat.data()[15] = 1.0
    return rmat

  rotatePoint: (point, angle) ->
    cc = Math.cos angle
    ss = Math.sin angle
    ic = 1 - cc
    u = @dir.data()[0]
    v = @dir.data()[1]
    w = @dir.data()[2]
    a = @base.data()[0]
    b = @base.data()[1]
    c = @base.data()[2]
    x = point.data()[0]
    y = point.data()[1]
    z = point.data()[2]
    point.data()[0] =
      (a * (v * v + w * w) - u * (b * v + c * w - u * x - v * y - w * z)) *
      ic + x * cc + (-c * v + b * w - w * y + v * z) * ss
    point.data()[1] =
      (b * (u * u + w * w) - v * (a * u + c * w - u * x - v * y - w * z)) *
      ic + y * cc + (c * u - a * w + w * x - u * z) * ss
    point.data()[2] =
      (c * (u * u + v * v) - w * (a * u + b * v - u * x - v * y - w * z)) *
      ic + z * cc + (-b * u + a * v - v * x + u * y) * ss
    return point

  rotatePointC: (point, angle) ->
    return @rotatePoint point.copy(), point

  @fromPoints: (p1, p2) ->
    return new Line p1.copy(), p2.subVecC(p1).normalize()

class window.Plane

  constructor: (@base, unorm) ->
    @norm = new Vec 3, unorm.data().slice()
    @norm.normalize()

  coloredLineSegs: (dist1, dist2, color = new Vec(3, [1.0, 1.0, 1.0])) ->
    dir1 = Vec.orthogonalVec(@norm).normalize()
    dir2 = Vec.crossProd3(@norm, dir1).normalize()

    line1 = new Line @base, dir1
    line2 = new Line @base, dir2

    prim1 = line1.toColoredLineSeg -dist1 / 2.0, dist1
    prim2 = line2.toColoredLineSeg -dist2 / 2.0, dist2

    return [prim1, prim2]

  coloredRect: (dist, angle, color = new Vec(3, [1.0, 1.0, 1.0])) ->
    dir1 = Vec.orthogonalVec(@norm).normalize()
    dir2 = Vec.crossProd3(@norm, dir1).normalize()

    dist /= 2.0

    nline = new Line @base, @norm
    rmat = nline.getRotationMatrix angle

    vec1 = @base.addVecC(dir1.multScalarC(dist)).toHomVecC().multMat(rmat)
    vec2 = @base.addVecC(dir2.multScalarC(dist)).toHomVecC().multMat(rmat)
    vec3 = @base.addVecC(dir1.multScalarC(-dist)).toHomVecC().multMat(rmat)
    vec4 = @base.addVecC(dir2.multScalarC(-dist)).toHomVecC().multMat(rmat)

    vert1 = new Vertex([vec1, color])
    vert2 = new Vertex([vec2, color])
    vert3 = new Vertex([vec3, color])
    vert4 = new Vertex([vec4, color])

    prim1 = new Primitive 3, [vert1, vert2, vert3]
    prim2 = new Primitive 3, [vert3, vert4, vert1]

    return [prim1, prim2]

  coloredRegNGon: (n, cdist, color = new Vec(3, [1.0, 1.0, 1.0])) ->

  getPlaneParam: ->
    return @norm.data().concat -Vec.scalarProd(@norm, @base)


class window.Polygon

  constructor: (@points) ->

  rotateAroundLine: (line, angle) ->
    rmat = line.getRotationMatrix angle
    p.multMat rmat for p in @points

  coloredOutline: (color = new Vec(3, [1.0, 1.0, 1.0])) ->
    verts = []
    n = @points.length
    verts.push(new Vertex([@points[i], color])) for i in [0..n-1]
    prims = []
    prims.push(new Primitive 2, [verts[i], verts[i + 1]]) for i in [0..n-2]
    prims.push(new Primitive 2, [verts[n - 1], verts[0]])
    return prims

  # only working for convex polygons
  coloredArea: (color = new Vec(3, [1.0, 1.0, 1.0])) ->
    verts = []
    n = @points.length
    verts.push(new Vertex([@points[i], color])) for i in [0..n-1]
    prims = []
    for i in [0..n-2]
      prims.push(new Primitive 3, [verts[0], verts[i], verts[i + 1]])
    return prims

  @regularFromLine: (line, n, cdist) ->
    angle = 2.0 * Math.PI / n
    vecs = []
    dir = Vec.orthogonalVec(line.dir).normalize()
    for i in [0..n-1]
      vec = line.base.addVecC(dir.multScalarC cdist)
      line.rotatePoint vec, angle * i
      vecs.push vec.toHomVecC()
    return new Polygon vecs

  @lineconnectPolys: (poly1, poly2, color = new Vec 3, [1.0, 1.0, 1.0]) ->
    prims = []
    p2points = poly2.points.slice()
    for p1 in poly1.points
      minp2 = undefined
      mindist = 100000
      for p2 in p2points
        if p1.distance(p2) < mindist
          minp2 = p2
          mindist = p1.distance(p2)
      vert1 = new Vertex [p1.copy(), color]
      vert2 = new Vertex [minp2, color]
      prims.push new Primitive 2, [vert1, vert2]
      p2points.splice(p2points.indexOf(minp2), 1)
    return prims

  @triangleconnectPolys: (poly1, poly2, color = new Vec 3, [1.0, 1.0, 1.0]) ->
    prims = []
    usedInd = []
    usedInd.push -1 for i in [1..n]
    n = poly1.points.length
    for i in [0..n-1]
      p1 = poly1.points[i]
      mindist = 100000
      for j in [0..n-1]
        p2 = poly2.points[j]
        if p1.distance(p2) < mindist and usedInd.indexOf(j) == -1
          mindist = p1.distance(p2)
          usedInd[i] = j
      minp2 = usedInd[usedInd.length-1]
      console.log minp2
      vert1 = new Vertex [poly1.points[i].copy(), color]
      vert2 = new Vertex [poly2.points[minp2].copy(), color]
      vert3 = new Vertex [poly1.points[(i + 1) %% n].copy(), color]
      vert4 = new Vertex [poly2.points[(minp2 + 1) %% n].copy(), color]
      color = color.subVecC new Vec 3, [1.0 / n, 0, 0]
      prims.push new Primitive 3, [vert1, vert2, vert3]
      prims.push new Primitive 3, [vert2, vert3, vert4]
    return prims
