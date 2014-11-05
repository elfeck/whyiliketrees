class window.Vec

  constructor: (@dim, @data = []) ->
    if @data.length == 0
      @data.push 0.0 for i in [1..dim] by 1

  addVec: (v) ->
    if v.dim != @dim
      console.log "Mismatched dim in vector add"
    for i in [0..@dim-1] by 1
      @data[i] += v.data[i]
    return this

  multScalar: (s) ->
    for i in [0..@dim-1] by 1
      @data[i] *= s
    return this

  multMat: (m) ->
    if m.dimX is not @dim
      console.log "Mismatched dim in vector-mat mult"

    newdata = []
    newdata.push 0.0 for i in [1..@dim] by 1
    for mr in [0..m.dimY-1] by 1
      for vr in [0..m.dimX-1] by 1
        newdata[mr] += m.data[mr * m.dimX + vr] * @data[vr]
    @data = newdata
    return this

  normalize: ->
    len = @length()
    @data[i] /= len for i in [0..@dim-1] by 1
    return this

  length: ->
    sum = 0
    sum += xx * xx for xx in @data by 1
    return Math.sqrt(sum)

  asUniformGL: (loc) ->
    switch @data.length
      when 1 then GL.uniform1f loc, @data[0]
      when 2 then GL.uniform2f loc, @data[0], @data[1]
      when 3 then GL.uniform3f loc, @data[0], @data[1], @data[2]
      when 4 then GL.uniform4f loc, @data[0], @data[1], @data[2], @data[3]
      else console.log "Invalid Uniform Attempt in math.coffee::Vec"
    return

  @multScalar: (v, s) ->
    nv = new Vec v.dim, v.data.slice()
    return nv.multScalar s

class window.Mat

  constructor: (@dimX, @dimY, @data = []) ->
    if @data.length == 0
      @data.push 0.0 for i in [1..@dimX*@dimY] by 1

  toId: ->
    if(not @dimX == @dimY)
      console.log "Cannot load id on unsym Mat in math.coffe::Mat"
    else
      @data[i * @dimX + i] = 1.0 for i in [0..@dimY - 1] by 1
    return this

  setTo: (m) ->
    @dimX = m.dimX
    @dimY = m.dimY
    @data = m.data.slice()
    return this

  asUniformGL: (loc) ->
    switch @dimX
      when 2 then GL.uniformMatrix2fv loc, false, new Float32Array @data
      when 3 then GL.uniformMatrix3fv loc, false, new Float32Array @data
      when 4 then GL.uniformMatrix4fv loc, false, new Float32Array @data
      else console.log "Invalid Uniform Attempt in math.coffe::Mat"
    return

  @mult: (a, b) ->
    if a.dimX is not b.dimY
      console.log "Cannot mult 2 Mat with mismatched dims in math.coffee"

    c = new Mat b.dimX, a.dimY

    for ar in [0..a.dimY-1] by 1
      for bc in [0..b.dimX-1] by 1
        for ac in [0..a.dimX-1] by 1
          c.data[c.dimX * ar + bc] += a.data[a.dimX * ar + ac] *
            b.data[b.dimX * ac + bc]

    return c
