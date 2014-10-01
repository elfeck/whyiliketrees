class window.Vec

  constructor: (@data = [0, 0]) ->

  asUniformGL: (loc) ->
    switch @data.length
      when 1 then GL.uniform1f loc, @data[0]
      when 2 then GL.uniform2f loc, @data[0], @data[1]
      when 3 then GL.uniform3f loc, @data[0], @data[1], @data[2]
      when 4 then GL.uniform4f loc, @data[0], @data[1], @data[2], @data[3]
      else console.log "Invalid Uniform Attempt in math.coffee"

class window.Mat

  constructor: (@data = [[1, 0], [0, 1]]) ->

  asUniformGL: (loc) ->
    switch @data.length
      when 2 then GL.uniformMatrix2fv loc, false, new Float32Array @toArray()
      when 3 then GL.uniformMatrix3fv loc, false, new Float32Array @toArray()
      when 4 then GL.uniformMatrix4fv loc, false, new Float32Array @toArray()

  toArray: ->
    return [].concat @data...
