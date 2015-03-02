class window.Line

  constructor: (@base, @dir) ->

  pointAtDistance: (dist) ->
    return @base.addVecC(@dir.multScalarC(dist))

  toColoredLineSeg: (bdist, length, color = new Vec(3, [1.0, 1.0, 1.0])) ->
    verts = [
      new Vertex([@pointAtDistance(bdist).toHomVecC(), color]),
      new Vertex([@pointAtDistance(bdist + length).toHomVecC(), color])
    ]
    prim = new Primitive 2, verts
    return prim

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

  rotatePoint: (angle, point) ->
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

  rotatePoint_N: (angle, point) ->
    return @rotatePoint angle, point.copy()

class window.Plane

  constructor: (@base, unorm) ->
    @norm = new Vec 3, unorm.data().slice()
    @norm.normalize()

  toColoredLineSegs: (dist1, dist2, color = new Vec(3, [1.0, 1.0, 1.0])) ->
    dir1 = Vec.orthogonalVec(@norm).normalize()
    dir2 = Vec.crossProd3(@norm, dir1).normalize()

    line1 = new Line @base, dir1
    line2 = new Line @base, dir2

    prim1 = line1.toColoredLineSeg -dist1 / 2.0, dist1
    prim2 = line2.toColoredLineSeg -dist2 / 2.0, dist2

    return [prim1, prim2]

  toColoredRect: (dist, angle, color = new Vec(3, [1.0, 1.0, 1.0])) ->
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

  getPlaneParam: ->
    return @norm.data().concat -Vec.scalarProd(@norm, @base)
