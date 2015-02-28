class window.Line

  constructor: (@base, @dir) ->

  pointAtDistance: (dist) ->
    return Vec.addVec @base, Vec.multScalar(@dir, dist)

  toColoredLineSeg: (bdist, length, color = new Vec(3, [1.0, 1.0, 1.0])) ->
    verts = [
      new Vertex([@pointAtDistance(bdist).toHomVec(), color]),
      new Vertex([@pointAtDistance(bdist + length).toHomVec(), color])
    ]
    prim = new Primitive 2, verts
    return prim


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

  toColoredRect: (dist, color = new Vec(3, [1.0, 1.0, 1.0])) ->
    dir1 = Vec.orthogonalVec(@norm).normalize()
    dir2 = Vec.crossProd3(@norm, dir1).normalize()

    dist /= 2.0

    vert1 = new Vertex(
      [Vec.addVec(@base, Vec.multScalar(dir1, dist)).toHomVec(), color])
    vert2 = new Vertex(
      [Vec.addVec(@base, Vec.multScalar(dir2, dist)).toHomVec(), color])
    vert3 = new Vertex(
      [Vec.addVec(@base, Vec.multScalar(dir1, -dist)).toHomVec(), color])
    vert4 = new Vertex(
      [Vec.addVec(@base, Vec.multScalar(dir2, -dist)).toHomVec(), color])

    prim1 = new Primitive 3, [vert1, vert2, vert3]
    prim2 = new Primitive 3, [vert3, vert4, vert1]

    return [prim1, prim2]

  getPlaneParam: ->
    return @norm.data().concat(-Vec.scalarProd @norm, @base)
