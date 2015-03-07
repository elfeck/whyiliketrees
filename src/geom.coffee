class window.Geom

  constructor: (@_layout) ->
    @_datasets = []

    @_vb = undefined
    @_ib = undefined

    @_stride = 0
    @_stride += s for s in @_layout

  initGL: ->
    @_vb = GL.createBuffer()
    @_ib = GL.createBuffer()
    return

  drawGL: () ->
    @bindGL()
    for d in @_datasets
      continue if not d.visible
      d.program.bindGL()
      d.program.uploadUniformsGL 0
      d.program.uploadUniformsGL d.id
      GL.drawElements(d.mode, d.getICount(), GL.UNSIGNED_SHORT,
        d.iOffs * 2)
      d.program.unbindGL()
    @unbindGL()
    return

  uploadGL: ->
    GL.bindBuffer GL.ARRAY_BUFFER, @_vb
    GL.bufferData GL.ARRAY_BUFFER, new Float32Array(@fetchVertexData()),
      GL.STATIC_DRAW
    GL.bindBuffer GL.ARRAY_BUFFER, null

    GL.bindBuffer GL.ELEMENT_ARRAY_BUFFER, @_ib
    GL.bufferData GL.ELEMENT_ARRAY_BUFFER, new Int16Array(@fetchIndexData()),
      GL.STATIC_DRAW
    GL.bindBuffer GL.ELEMENT_ARRAY_BUFFER, null
    return

  updateGL: () ->
    @uploadGL()
    return

  addData: (geomData) ->
    @_datasets.push geomData
    iOffs = 0
    for ds in @_datasets
      ds.iOffs = iOffs
      iOffs += ds.getICount()
    @uploadGL()
    return

  fetchVertexData: ->
    vRaw = []
    ds.fetchVertexData vRaw for ds in @_datasets
    return vRaw

  fetchIndexData: ->
    iRaw = []
    offs = 0
    offs = ds.fetchIndexData iRaw, offs for ds in @_datasets
    return iRaw

  bindGL: ->
    GL.bindBuffer GL.ARRAY_BUFFER, @_vb
    GL.bindBuffer GL.ELEMENT_ARRAY_BUFFER, @_ib
    GL.enableVertexAttribArray i for i in [0..@_layout.length-1]
    offs = 0
    for own index, size of @_layout
      @setAttribGL index, size, offs
      offs += size
    return

  unbindGL: ->
    GL.bindBuffer GL.ARRAY_BUFFER, null
    GL.bindBuffer GL.ELEMENT_ARRAY_BUFFER, null
    GL.disableVertexAttribArray i for i in [0..@_layout.length-1]
    return

  setAttribGL: (i, s, offs) ->
    GL.vertexAttribPointer i, s, GL.FLOAT, false, @_stride * 4, offs * 4
    return



# #################
# Container classes
# #################

class window.GeomData

  constructor: (@id, @program = undefined, @prims = [],
    @mode = GL.TRIANGLES, @visible = true) ->
    @vOffs = 0
    @iOffs = 0

  getICount: ->
    return 0 if @prims.length is 0
    return @prims.length * @prims[0].vCount

  checkMod: ->


  fetchVertexData: (vRaw) ->
    p.fetchVertexData vRaw for p in @prims
    return

  fetchIndexData: (iRaw, offs) ->
    offs = p.fetchIndexData iRaw, offs for p in @prims
    return offs


class window.Primitive

  constructor: (@vCount, @vertices = []) ->

  fetchVertexData: (vRaw) ->
    v.fetchVertexData vRaw for v in @vertices
    return

  fetchIndexData: (iRaw, offs) ->
    iRaw.push(i + offs) for i in [0..@vCount-1] by 1
    return offs + @vCount

  vertexNormalLines: (length, color) ->
    if @vCount is not 3
      window.dprint "No triangle, no normal"
    prims = []
    for v in @vertices
      line = new Line v.data[0].stripHomC(), v.data[2].copy().normalize()
      prims = prims.concat line.coloredLineSegC(0, length, color)
    return prims

  centroidNormalLines: (length, color) ->
    if @vCount is not 3
      window.dprint "No triangle, no normal"
    centroid = new Vec 3
    for v in @vertices
      centroid.addVec v.data[0].stripHomC()
    line = new Line centroid.multScalar(1.0 / 3.0),
      @vertices[0].data[2].normalizeC()
    return line.coloredLineSegC 0, length, color


class window.Vertex

  constructor: (@data = []) ->

  fetchVertexData: (vRaw) ->
    v.fetchVertexData vRaw for v in @data
    return
