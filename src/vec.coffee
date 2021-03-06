class window.Vec

  constructor: (@data, @asHom = false) ->
    @dim = @data.length

  copy: ->
    return new Vec @data.slice(), @asHom

  isZeroVec: ->
    return isFloatZero @length()

  setData: (data) ->
    @data = data.slice()
    return this

  setTo: (vec) ->
    @data = vec.data.slice()
    @dim = vec.dim
    return this

  addVec: (v) ->
    if v.dim != @dim
      window.dprint "Mismatched dim in vector add " + @dim + " vs " + v.dim
    @data[i] += v.data[i] for i in [0..@dim-1] by 1
    return this

  subVec: (v) ->
    if v.dim != @dim
      window.dprint "Mismatched dim in vector add/sub"
    @data[i] -= v.data[i] for i in [0..@dim-1] by 1
    return this

  multVec: (v) ->
    if v.dim != @dim
      window.dprint "Mismatched dim in vector mult"
    @data[i] *= v.data[i] for i in [0..@dim-1] by 1
    return this

  multScalar: (s) ->
    @data[i] *= s for i in [0..@dim-1] by 1
    return this

  multMat: (m) ->
    if m.dimX != @dim
      window.dprint "Mismatched dim in vector-mat mult"
    newdata = []
    newdata.push 0.0 for i in [1..@dim] by 1
    for mr in [0..m.dimY-1] by 1
      for vr in [0..m.dimX-1] by 1
        newdata[mr] += m.data[vr * m.dimX + mr] * @data[vr]
    @setData newdata
    return this

  normalize: ->
    len = @length()
    @data[i] /= len for i in [0..@dim-1] by 1
    return this

  length: ->
    sum = 0
    sum += xx * xx for xx in @data by 1
    return Math.sqrt(sum)

  distance: (v) ->
    return v.subVecC(this).length()

  toHomVec: ->
    if @dim < 2 or @dim > 4 or @asHom
      window.dprint "toHomVec invalid dim / asHom"
      return undefined
    @data.push 0.0 if @dim <= 2
    @data.push 1.0 if @dim <= 3
    return this

  toHomVecC: ->
    if @dim < 2 or @dim > 4 or @asHom
      window.dprint "toHomVecC invalid dim / asHom: " + @dim + " " + @asHom
      return undefined
    newdata = @data.slice()
    newdata.push 0.0 if @dim <= 2
    newdata.push 1.0 if @dim <= 3
    return new Vec newdata

  fromHomVecC: ->
    if @dim != 4 and !@asHom
      window.dprint "fromHomVecC invalid dim"
      return undefined
    newdata = []
    newdata.push @data[i] for i in [0..2]
    vec = new Vec newdata
    return vec.multScalar(1.0 / @data[3])

  stripHomC: ->
    if @dim != 4 and !@asHom
      window.dprint "stripHomC invalid dim"
      return undefined
    newdata = []
    newdata.push @data[i] for i in [0..2]
    return new Vec newdata

  scalarProd: (v) ->
    if not @dim is v.dim
      window.dprint "Invalid vector dims for scalarProd"
    sum = 0
    sum += @data[i] * v.data[i] for i in [0..@dim-1]
    return sum

  asUniformGL: (loc) ->
    switch @data.length
      when 1 then GL.uniform1f loc, @data[0]
      when 2 then GL.uniform2f loc, @data[0], @data[1]
      when 3 then GL.uniform3f loc, @data[0], @data[1], @data[2]
      when 4 then GL.uniform4f loc, @data[0], @data[1], @data[2], @data[3]
      else window.dprint "Invalid Uniform Attempt in math.coffee::Vec"
    return

  fetchVertexData: (vRaw) ->
    vRaw.push i for i in @data
    vRaw.push 1.0 if @asHom
    return

  x: -> return @data[0]
  y: -> return @data[1]
  z: -> return @data[2]
  w: -> return @data[3]

  # utility methods
  addVecC: (v) -> return @copy().addVec v
  subVecC: (v) -> return @copy().subVec v
  multVecC: (v) -> return @copy().multVec v
  multScalarC: (s) -> return @copy().multScalar s
  multMatC: (m) -> return @copy().multMat m
  normalizeC: -> return @copy().normalize()
  @addVec: (v1, v2) -> return v1.addVecC v2
  @subVec: (v1, v2) -> return v1.subVecC v2
  @multVec: (v1, v2) -> return v1.multVecC v2
  @multScalar: (v, s) -> return v.multScalarC s
  @normalize: (v) -> return v.normalizeC()
  @distance: (v1, v2) -> return v1.distance v2
  @toHomVec: (v) -> return v.toHomVecC()
  @fromHomVec: (v) -> return v.fromHomVecC()
  @scalarProd: (v1, v2) -> return v1.scalarProd v2

  @crossProd3: (u, v) ->
    if u.dim != 3 or v.dim != 3
      window.dprint "invalid vector dims for crossProd3"
      return undefined
    cprod = Vec.zeros 3
    cprod.data[0] = u.data[1] * v.data[2] - u.data[2] * v.data[1]
    cprod.data[1] = u.data[2] * v.data[0] - u.data[0] * v.data[2]
    cprod.data[2] = u.data[0] * v.data[1] - u.data[1] * v.data[0]
    return cprod

  @surfaceNormal: (a, b, c) ->
    if a.dim < 3 and b.dim < 3 and c.dim < 3
      window.dprint "Invalid vector dims for surface normal"
      return undefined
    u = Vec.subVec a, b
    v = Vec.subVec c, b
    n = new Vec [
      u.data[1] * v.data[2] - u.data[2] * v.data[1],
      u.data[2] * v.data[0] - u.data[0] * v.data[2],
      u.data[0] * v.data[1] - u.data[1] * v.data[0]
    ]
    return n.normalize()

  @orthogonalVec: (v) ->
    for i in [0..v.dim-1]
      continue if v.data[i] == 0
      sum = 0
      (sum -= v.data[j] if j != i) for j in [0..v.dim-1]
      sum /= v.data[i]
      w = Vec.zeros v.dim
      for j in [0..v.dim-1]
        if j == i
          w.data[j] = sum
        else
          w.data[j] = 1
      return w
    return undefined

  @angleBetween: (a, b) ->
    return Math.acos(Vec.scalarProd(a, b) / (a.length() * b.length()))

  # only for dim = 3
  # http://www.wolframalpha.com/input/
  # ?i=sqrt%28%28p_1+%2B+s*q_1%29%C2%B2+%2B+%28p_2+%2B+s*q_2%29%
  # C2%B2+%2B+%28p_3+%2B+s*q_3%29%C2%B2%29+%3D+r+for+s
  @scalarForLengthMatch3: (point, dir, d) ->
    p1 = point.x()
    p2 = point.y()
    p3 = point.z()
    q1 = point.x()
    q2 = point.y()
    q3 = point.z()
    s = 1.0 / (2 * (q1 * q1 + q2 * q2 + q3 * q3))
    t1 = Math.pow((2*p1*q1 + 2*p2*q2 + 2*p3*q3), 2)
    t2 = -4 * (q1*q1 + q2*q2 + q3*q3) * (p1*p1 + p2*p2 + p3*p3 - d*d)
    t3 = -2*p1*q1 * 2*p2*q2 - 2*p3*q3
    return s * Math.sqrt(t1 + t2 + t3)

  @zeros: (dim) ->
    data = []
    data.push 0 for i in [1..dim]
    return new Vec data

  @ones: (dim) ->
    data = []
    data.push 1 for i in [1..dim]
    return new Vec data

  @red: -> return new Vec [1, 0, 0]
  @green: -> return new Vec [0, 1, 0]
  @blue: -> return new Vec [0, 0, 1]
