class window.Vec

  constructor: (@dim, @_data = []) ->
    if @_data.length == 0
      @_data.push 0.0 for i in [1..dim] by 1
    @_mod = true

  copy: ->
    return new Vec @dim, @_data.slice()

  data: ->
    @_mod = true
    return @_data

  setData: (data) ->
    @_mod = true
    @_data = data.slice()
    return this

  addVec: (v) ->
    @_mod = true
    if v.dim != @dim
      window.dprint "Mismatched dim in vector add"
    @_data[i] += v.data()[i] for i in [0..@dim-1] by 1
    return this

  subVec: (v) ->
    @_mod = true
    if v.dim != @dim
      window.dprint "Mismatched dim in vector add/sub"
    @_data[i] -= v.data()[i] for i in [0..@dim-1] by 1
    return this


  multVec: (v) ->
    @_mod = true
    if v.dim != @dim
      window.dprint "Mismatched dim in vector mult"
    @_data[i] *= v.data()[i] for i in [0..@dim-1] by 1
    return this

  multScalar: (s) ->
    @_mod = true
    @_data[i] *= s for i in [0..@dim-1] by 1
    return this


  multMat: (m) ->
    @_mod = true
    if m.dimX is not @dim
      window.dprint "Mismatched dim in vector-mat mult"
    newdata = []
    newdata.push 0.0 for i in [1..@dim] by 1
    for mr in [0..m.dimY-1] by 1
      for vr in [0..m.dimX-1] by 1
        newdata[mr] += m.data()[vr * m.dimX + mr] * @_data[vr]
    @setData newdata
    return this

  normalize: ->
    @_mod = true
    len = @length()
    @_data[i] /= len for i in [0..@dim-1] by 1
    return this

  length: ->
    sum = 0
    sum += xx * xx for xx in @_data by 1
    return Math.sqrt(sum)

  distance: (v) ->
    return v.subVecC(this).length()

  toHomVecC: ->
    if @dim < 2 or @dim > 4
      window.dprint "toHomVec invalid dim"
      return undefined
    newdata = @_data.slice()
    newdata.push 0.0 if @dim <= 2
    newdata.push 1.0 if @dim <= 3
    return new Vec(4, newdata)

  scalarProd: (v) ->
    if not dim is v.dim
      window.dprint "Invalid vector dims for scalarProd"
    sum = 0
    sum += data()[i] * v.data()[i] for i in [0..dim-1]
    return sum

  asUniformGL: (loc) ->
    switch @_data.length
      when 1 then GL.uniform1f loc, @_data[0]
      when 2 then GL.uniform2f loc, @_data[0], @_data[1]
      when 3 then GL.uniform3f loc, @_data[0], @_data[1], @_data[2]
      when 4 then GL.uniform4f loc, @_data[0], @_data[1], @_data[2], @_data[3]
      else window.dprint "Invalid Uniform Attempt in math.coffee::Vec"
    @_mod = false
    return

  fetchVertexData: (vRaw) ->
    vRaw.push i for i in @_data
    @_mod = false
    return

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
  @scalarProd: (v1, v2) -> return v1.scalarProd v2

  @crossProd3: (u, v) ->
    if u.dim != 3 or v.dim != 3
      window.dprint "invalid vector dims for crossProd3"
      return undefined
    cprod = new Vec 3
    cprod.data()[0] = u.data()[1] * v.data()[2] - u.data()[2] * v.data()[1]
    cprod.data()[1] = u.data()[2] * v.data()[0] - u.data()[0] * v.data()[2]
    cprod.data()[2] = u.data()[0] * v.data()[1] - u.data()[1] * v.data()[0]
    return cprod

  @surfaceNormal: (a, b, c) ->
    if a.dim < 3 and b.dim < 3 and c.dim < 3
      window.dprint "Invalid vector dims for surface normal"
      return undefined
    u = Vec.subVec a, b
    v = Vec.subVec c, b
    n = new Vec 3, [
      u.data()[1] * v.data()[2] - u.data()[2] * v.data()[1],
      u.data()[2] * v.data()[0] - u.data()[0] * v.data()[2],
      u.data()[0] * v.data()[1] - u.data()[1] * v.data()[0]
    ]
    return n

  @orthogonalVec: (v) ->
    for i in [0..v.dim-1]
      continue if v.data()[i] == 0
      sum = 0
      (sum -= v.data()[j] if j != i) for j in [0..v.dim-1]
      sum /= v.data()[i]
      w = new Vec v.dim
      for j in [0..v.dim-1]
        if j == i
          w.data()[j] = sum
        else
          w.data()[j] = 1
      return w
    return undefined

class window.Mat

  constructor: (@dimX, @dimY, @_data = []) ->
    @_mod = true
    if @_data.length == 0
      @_data.push 0.0 for i in [1..@dimX*@dimY] by 1

  data: ->
    @_mod = true
    return @_data

  toId: ->
    @_mod = true
    if(not @dimX == @dimY)
      window.dprint "Cannot load id on unsym Mat in math.coffe::Mat"
    else
      @_data[i * @dimX + i] = 1.0 for i in [0..@dimY - 1] by 1
    return this

  multFromLeft: (b) ->
    a = this
    if a.dimX is not b.dimY
      window.dprint "Cannot mult 2 Mat with mismatched dims in math.coffee"
    c = new Mat b.dimX, a.dimY
    for ar in [0..a.dimY-1] by 1
      for bc in [0..b.dimX-1] by 1
        for ac in [0..a.dimX-1] by 1
          c.data()[c.dimX * ar + bc] += a.data()[a.dimX * ar + ac] *
            b.data()[b.dimX * ac + bc]
    @setData c.data()
    return this

  multFromRight: (a) ->
    b = this
    if a.dimX is not b.dimY
      window.dprint "Cannot mult 2 Mat with mismatched dims in math.coffee"
    c = new Mat b.dimX, a.dimY
    for ar in [0..a.dimY-1] by 1
      for bc in [0..b.dimX-1] by 1
        for ac in [0..a.dimX-1] by 1
          c.data()[c.dimX * ar + bc] += a.data()[a.dimX * ar + ac] *
            b.data()[b.dimX * ac + bc]
    @setData c.data()
    return this

  setTo: (m) ->
    @_mod = true
    @dimX = m.dimX
    @dimY = m.dimY
    @setData m.data()
    return this

  setData: (data) ->
    @_mod = true
    @_data = data.slice()
    return this

  asUniformGL: (loc) ->
    switch @dimX
      when 2 then GL.uniformMatrix2fv loc, false, new Float32Array @_data
      when 3 then GL.uniformMatrix3fv loc, false, new Float32Array @_data
      when 4 then GL.uniformMatrix4fv loc, false, new Float32Array @_data
      else window.dprint "Invalid Uniform Attempt in math.coffe::Mat"
    @_mod = false
    return

  @mult: (a, b) ->
    if a.dimX is not b.dimY
      window.dprint "Cannot mult 2 Mat with mismatched dims in math.coffee"
    c = new Mat b.dimX, a.dimY
    for ar in [0..a.dimY-1] by 1
      for bc in [0..b.dimX-1] by 1
        for ac in [0..a.dimX-1] by 1
          c.data()[c.dimX * ar + bc] += a.data()[a.dimX * ar + ac] *
            b.data()[b.dimX * ac + bc]
    return c
