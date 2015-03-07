class window.Mat

  constructor: (@dimX, @dimY, @data = []) ->
    (@data.push 0.0 for i in [1..@dimX*@dimY] by 1) if @data.length == 0

  toId: ->
    if(not @dimX == @dimY)
      window.dprint "Cannot load id on unsym Mat in math.coffe::Mat"
    else
      @data[i * @dimX + i] = 1.0 for i in [0..@dimY - 1] by 1
    return this

  multFromLeft: (b) ->
    a = this
    if a.dimX is not b.dimY
      window.dprint "Cannot mult 2 Mat with mismatched dims in math.coffee"
    c = new Mat b.dimX, a.dimY
    for ar in [0..a.dimY-1] by 1
      for bc in [0..b.dimX-1] by 1
        for ac in [0..a.dimX-1] by 1
          c.data[c.dimX * ar + bc] += a.data[a.dimX * ar + ac] *
            b.data[b.dimX * ac + bc]
    @setData c.data
    return this

  multFromRight: (a) ->
    b = this
    if a.dimX is not b.dimY
      window.dprint "Cannot mult 2 Mat with mismatched dims in math.coffee"
    c = new Mat b.dimX, a.dimY
    for ar in [0..a.dimY-1] by 1
      for bc in [0..b.dimX-1] by 1
        for ac in [0..a.dimX-1] by 1
          c.data[c.dimX * ar + bc] += a.data[a.dimX * ar + ac] *
            b.data[b.dimX * ac + bc]
    @setData c.data
    return this

  setTo: (m) ->
    @dimX = m.dimX
    @dimY = m.dimY
    @setData m.data
    return this

  setData: (data) ->
    @data = data.slice()
    return this

  asUniformGL: (loc) ->
    switch @dimX
      when 2 then GL.uniformMatrix2fv loc, false, new Float32Array @data
      when 3 then GL.uniformMatrix3fv loc, false, new Float32Array @data
      when 4 then GL.uniformMatrix4fv loc, false, new Float32Array @data
      else window.dprint "Invalid Uniform Attempt in math.coffe::Mat"
    return

  @mult: (a, b) ->
    if a.dimX is not b.dimY
      window.dprint "Cannot mult 2 Mat with mismatched dims in math.coffee"
    c = new Mat b.dimX, a.dimY
    for ar in [0..a.dimY-1] by 1
      for bc in [0..b.dimX-1] by 1
        for ac in [0..a.dimX-1] by 1
          c.data[c.dimX * ar + bc] += a.data[a.dimX * ar + ac] *
            b.data[b.dimX * ac + bc]
    return c
