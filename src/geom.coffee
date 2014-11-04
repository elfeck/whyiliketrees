class window.Geom

  constructor: ->
    @vData = []
    @iData = []

    @_stride = 0
    @_vb = undefined
    @_ib = undefined

    @_layout = []

  initGL: (program, attribNames) ->
    @_vb = GL.createBuffer()
    @_ib = GL.createBuffer()

    #GL.bindBuffer(GL.ARRAY_BUFFER, @_vb)
    #GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, @_ib)

    offset = 0
    for own name, size of attribNames
      @_layout[program.getAttribLocGL(name)] = [size, offset]
      offset += size
      @_stride += size

    #GL.bindBuffer(GL.ARRAY_BUFFER, null)
    #GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, null)

  uploadGL: ->
    GL.bindBuffer GL.ARRAY_BUFFER, @_vb
    GL.bufferData GL.ARRAY_BUFFER, new Float32Array(@vData),
      GL.STATIC_DRAW
    GL.bindBuffer GL.ARRAY_BUFFER, null

    GL.bindBuffer GL.ELEMENT_ARRAY_BUFFER, @_ib
    GL.bufferData GL.ELEMENT_ARRAY_BUFFER, new Int16Array(@iData),
      GL.STATIC_DRAW
    GL.bindBuffer GL.ELEMENT_ARRAY_BUFFER, null

  updateGL: ->
    # for now just inefficient re-upload of the whole buffer
    @uploadGL()

  bindGL: ->
    GL.bindBuffer GL.ARRAY_BUFFER, @_vb
    GL.bindBuffer GL.ELEMENT_ARRAY_BUFFER, @_ib

    for own index, info of @_layout
      @setAttribGL index, info[0], info[1]

  unbindGL: ->
    GL.bindBuffer GL.ARRAY_BUFFER, null
    GL.bindBuffer GL.ELEMENT_ARRAY_BUFFER, null

  setAttribGL: (index, size, offset) ->
    GL.enableVertexAttribArray index
    GL.vertexAttribPointer index, size, GL.FLOAT, false, @_stride * 4,
      offset * 4