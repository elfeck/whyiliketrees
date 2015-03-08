class window.Geom

  constructor: (@_layout) ->
    @_datasets = []
    @_vb = undefined
    @_ib = undefined
    @_modified = false
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
    GL.bufferData GL.ARRAY_BUFFER, new Float32Array(@fetchAllVertexData()),
      GL.STATIC_DRAW
    GL.bindBuffer GL.ARRAY_BUFFER, null

    GL.bindBuffer GL.ELEMENT_ARRAY_BUFFER, @_ib
    GL.bufferData GL.ELEMENT_ARRAY_BUFFER, new Int16Array(@fetchIndexData()),
      GL.STATIC_DRAW
    GL.bindBuffer GL.ELEMENT_ARRAY_BUFFER, null
    @_modified = false
    return

  updateGL: () ->
    return if @_datasets.length == 0
    if @_modified
      @uploadGL()
      return
    minInd = @_datasets.length
    maxInd = -1
    for i in [0..@_datasets.length-1]
      d = @_datasets[i]
      if d.modified
        minInd = Math.min(minInd, i)
        maxInd = Math.max(maxInd, i)
    if maxInd > -1
      GL.bindBuffer GL.ARRAY_BUFFER, @_vb
      GL.bufferSubData GL.ARRAY_BUFFER, @_datasets[minInd].vOffs * 4,
        new Float32Array(@fetchModVertexData(minInd, maxInd))
      #dprint "Updating Geom VBO from " + @_datasets[minInd].vOffs * 4 +
      #  " to " +
      #  (@_datasets[maxInd].vOffs + @_datasets[maxInd].getICount()) * 4
      GL.bindBuffer GL.ARRAY_BUFFER, null
    d.modified = false for d in @_datasets
    return

  addData: (geomData) ->
    @_modified = true
    @_datasets.push geomData
    iOffs = 0
    for ds in @_datasets
      ds.iOffs = iOffs
      ds.vOffs = iOffs * @_stride
      iOffs += ds.getICount()
    return

  fetchAllVertexData: ->
    vRaw = []
    ds.fetchVertexData vRaw for ds in @_datasets
    return vRaw

  fetchModVertexData: (minInd, maxInd) ->
    vRaw = []
    @_datasets[i].fetchVertexData vRaw for i in [minInd..maxInd]
    return vRaw

  fetchIndexData: ->
    iRaw = []
    offs = 0
    offs = ds.fetchIndexData iRaw, offs for ds in @_datasets
    return iRaw

  bindGL: ->
    @uploadGL() if @_modified
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
    @vOffs = 0 # in float-attrib entries (*4 to get to byte)
    @iOffs = 0 # in short-attrib entries (*2 to get to byte)
    @modified = false

  setModified: ->
    @modified = true

  getICount: ->
    return 0 if @prims.length is 0
    return @prims.length * @prims[0].vCount

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
