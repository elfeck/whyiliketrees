class window.Geom

  @debugTotalPrimCount = 0
  @debugTotalDrawCalls = 0
  @debugTotalUpdates = 0

  constructor: (@layout) ->
    @datasets = []
    @vb = undefined
    @ib = undefined
    @modified = false
    @stride = 0
    @stride += s for s in @layout

  initGL: ->
    @vb = GL.createBuffer()
    @ib = GL.createBuffer()
    return

  drawGL: () ->
    @bindGL()
    for d in @datasets
      continue if not d.visible
      Geom.debugTotalDrawCalls++
      d.program.bindGL()
      d.program.uploadUniformsGL 0
      d.program.uploadUniformsGL d.id
      GL.drawElements(d.mode, d.getICount(), GL.UNSIGNED_SHORT,
        d.iOffs * 2)
      d.program.unbindGL()
    @unbindGL()
    return

  uploadGL: ->
    GL.bindBuffer GL.ARRAY_BUFFER, @vb
    GL.bufferData GL.ARRAY_BUFFER, new Float32Array(@fetchAllVertexData()),
      GL.STATIC_DRAW
    GL.bindBuffer GL.ARRAY_BUFFER, null

    GL.bindBuffer GL.ELEMENT_ARRAY_BUFFER, @ib
    GL.bufferData GL.ELEMENT_ARRAY_BUFFER, new Int16Array(@fetchIndexData()),
      GL.STATIC_DRAW
    GL.bindBuffer GL.ELEMENT_ARRAY_BUFFER, null
    @modified = false
    return

  updateGL: () ->
    return if @datasets.length == 0
    if @modified
      Geom.debugTotalUpdates++
      @uploadGL()
      return
    minInd = @datasets.length
    maxInd = -1
    for i in [0..@datasets.length-1]
      d = @datasets[i]
      if d.modified
        minInd = Math.min(minInd, i)
        maxInd = Math.max(maxInd, i)
    if maxInd > -1
      Geom.debugTotalUpdates++
      GL.bindBuffer GL.ARRAY_BUFFER, @vb
      GL.bufferSubData GL.ARRAY_BUFFER, @datasets[minInd].vOffs * 4,
        new Float32Array(@fetchModVertexData(minInd, maxInd))
      #@dbgPrintUpdate minInd, maxInd
      GL.bindBuffer GL.ARRAY_BUFFER, null
    d.modified = false for d in @datasets
    return

  dbgPrintUpdate: (minInd, maxInd) ->
    msg = "Updating Geom VBO from " + @datasets[minInd].vOffs * 4 +
      " to " +
      (@datasets[maxInd].vOffs + @datasets[maxInd].getICount()) * 4 +
      " (of " +
      (@datasets[@datasets.length-1].vOffs +
      @datasets[@datasets.length-1].getICount()) * 4 +
      ")"
    dprint msg
    return

  addData: (geomData) ->
    Geom.debugTotalPrimCount += geomData.getPrimCount() #debug
    @modified = true
    @datasets.push geomData
    iOffs = 0
    for ds in @datasets
      ds.iOffs = iOffs
      ds.vOffs = iOffs * @stride
      iOffs += ds.getICount()
    return

  removeData: (geomData) ->
    Geom.debugTotalPrimCount -= geomData.getPrimCount()
    @modified = true
    # TODO

  fetchAllVertexData: ->
    vRaw = []
    ds.fetchVertexData vRaw for ds in @datasets
    return vRaw

  fetchModVertexData: (minInd, maxInd) ->
    vRaw = []
    @datasets[i].fetchVertexData vRaw for i in [minInd..maxInd]
    return vRaw

  fetchIndexData: ->
    iRaw = []
    offs = 0
    offs = ds.fetchIndexData iRaw, offs for ds in @datasets
    return iRaw

  bindGL: ->
    @uploadGL() if @modified
    GL.bindBuffer GL.ARRAY_BUFFER, @vb
    GL.bindBuffer GL.ELEMENT_ARRAY_BUFFER, @ib
    GL.enableVertexAttribArray i for i in [0..@layout.length-1]
    offs = 0
    for own index, size of @layout
      @setAttribGL index, size, offs
      offs += size
    return

  unbindGL: ->
    GL.bindBuffer GL.ARRAY_BUFFER, null
    GL.bindBuffer GL.ELEMENT_ARRAY_BUFFER, null
    GL.disableVertexAttribArray i for i in [0..@layout.length-1]
    return

  setAttribGL: (i, s, offs) ->
    GL.vertexAttribPointer i, s, GL.FLOAT, false, @stride * 4, offs * 4
    return


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

  getPrimCount: ->
    m = 1 if @mode == GL.POINTS
    m = 2 if @mode == GL.LINES
    m = 3 if @mode == GL.TRIANGLES
    return @getICount() / m

  dbgUpdate: ->
    p.dbgUpdate() for p in @prims
    return

  fetchVertexData: (vRaw) ->
    p.fetchVertexData vRaw for p in @prims
    return

  fetchIndexData: (iRaw, offs) ->
    offs = p.fetchIndexData iRaw, offs for p in @prims
    return offs


class window.Primitive

  constructor: (@vCount, @vertices = []) ->
    @dbgVertexLines = []
    @dbgCentroidLine = undefined

  fetchVertexData: (vRaw) ->
    v.fetchVertexData vRaw for v in @vertices
    return

  fetchIndexData: (iRaw, offs) ->
    iRaw.push(i + offs) for i in [0..@vCount-1] by 1
    return offs + @vCount

  dbgUpdate: ->
    if @dbgVertexLines.length != 0
      for i in [0..@vertices.length-1]
        @dbgVertexLines[i].setBase @vertices[i].data[0].stripHomC()
        @dbgVertexLines[i].setDir @vertices[i].data[2].normalizeC()
    if @dbgCentroidLine?
      centroid = new Vec 3
      centroid.addVec v.data[0].stripHomC() for v in @vertices
      centroid.multScalar(1.0 / 3.0)
      @dbgCentroidLine.setBase centroid
      @dbgCentroidLine.setDir @vertices[0].data[2].normalizeC()
    return

  dbgAddVertexNormals: (length = 2, color = new Vec(3, [0.0, 1.0, 0.0])) ->
    if @vCount is not 3
      window.dprint "dbgAddVertexNormals: No triangle, no normal"
      return []
    prims = []
    for v in @vertices
      line = new Line v.data[0].stripHomC(), v.data[2].normalizeC()
      @dbgVertexLines.push line
      prims = prims.concat line.gfxAddLineSeg(0, 2, color)
    return prims

  dbgAddCentroidNormal: (length = 2, color = new Vec 3, [0.0, 1.0, 0.0]) ->
    if @vCount is not 3
      window.dprint "dbgAddVertexNormals: No triangle, no normal"
      return []
    centroid = new Vec 3
    centroid.addVec v.data[0].stripHomC() for v in @vertices
    centroid.multScalar(1.0 / 3.0)
    @dbgCentroidLine = new Line centroid, @vertices[0].data[2].normalizeC()
    return @dbgCentroidLine.gfxAddLineSeg 0, length, color


class window.Vertex

  constructor: (@data = []) ->

  fetchVertexData: (vRaw) ->
    v.fetchVertexData vRaw for v in @data
    return
