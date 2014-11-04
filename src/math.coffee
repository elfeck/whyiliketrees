class window.Vec

  constructor: (@dim, @data = []) ->
    if @data.length == 0
      @data.push 0.0 for i in [1..dim] by 1

  asUniformGL: (loc) ->
    switch @data.length
      when 1 then GL.uniform1f loc, @data[0]
      when 2 then GL.uniform2f loc, @data[0], @data[1]
      when 3 then GL.uniform3f loc, @data[0], @data[1], @data[2]
      when 4 then GL.uniform4f loc, @data[0], @data[1], @data[2], @data[3]
      else console.log "Invalid Uniform Attempt in math.coffee::Vec"

class window.Mat

  constructor: (@dimX, @dimY, @data = []) ->
    if @data.length == 0
      @data.push 0.0 for i in [1..@dimX * @dimY] by 1

  toId: ->
    if(not @dimX == @dimY)
      console.log "Cannot load id on unsym Mat in math.coffe::Mat"
    else
      @data[i * @dimX + i] = 1.0 for i in [0..@dimY - 1] by 1

  setTo: (m) ->
    @dimX = m.dimX
    @dimY = m.dimY
    @data = m.data

  asUniformGL: (loc) ->
    switch @dimX
      when 2 then GL.uniformMatrix2fv loc, false, new Float32Array @data
      when 3 then GL.uniformMatrix3fv loc, false, new Float32Array @data
      when 4 then GL.uniformMatrix4fv loc, false, new Float32Array @data
      else console.log "Invalid Uniform Attempt in math.coffe::Mat"

  @mult: (a, b) ->
    if a.dimX is not b.dimY
      console.log "Cannot mult 2 Mat with missmatched dims in math.coffee"

    c = new Mat b.dimX, a.dimY

    for ar in [0..a.dimY - 1] by 1
      for bc in [0..b.dimX - 1] by 1
        for ac in [0..a.dimX - 1] by 1
          c.data[c.dimX * ar + bc] += a.data[a.dimX * ar + ac] *
            b.data[b.dimX * ac + bc]

    return c
