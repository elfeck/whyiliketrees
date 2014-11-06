class window.Geom

  constructor: ->
    @_datasets = []
    @_totalIOffs = 0 # total offset into the indexbuffer
    @_totalVOffs = 0 # total offset added to each index (to have 0-base)

    @_stride = 0
    @_vb = undefined
    @_ib = undefined
    @currentProgram = undefined

    # location: [size, offset]
    @_layout = []

  initGL: (program, attribNames) ->
    @_vb = GL.createBuffer()
    @_ib = GL.createBuffer()
    @currentProgram = program

    offset = 0
    for own name, size of attribNames
      index = program.getAttribLocGL(name)
      @_layout[index] = [size, offset]
      GL.enableVertexAttribArray index
      offset += size
      @_stride += size
    return

  drawGL: () ->
    @bindGL()
    @currentProgram.bindGL()
    @currentProgram.uploadUniformsGL 0

    for toDraw in @_datasets
      if toDraw?
        @currentProgram.uploadUniformsGL toDraw.id
        GL.drawElements(GL.TRIANGLES, toDraw.iRaw.length,
          GL.UNSIGNED_SHORT, toDraw.iOffs * 2)

    @currentProgram.unbindGL()
    @unbindGL()

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

  updateGL: (id) ->
    # for now just inefficient re-upload of the whole buffer
    @uploadGL()
    return

  addDataSet: (id, vRaw, iRaw) ->
    oiRaw = []
    vCount = 0
    for i in iRaw
      oiRaw.push i + @_totalVOffs
      vCount = Math.max(vCount, i)
    vCount++
    @_totalVOffs += vCount
    dataset =
      id: id
      vRaw: vRaw
      iRaw: oiRaw
      iOffs: @_totalIOffs # offset into the actual index buffer
      vCount: vCount      # count of vertices in this dataset

    @_datasets.push dataset
    @_totalIOffs += iRaw.length

    @uploadGL()
    return

  removeDataSet: (id) ->
    toRemove = @getDataSet id
    index = @_datasets.indexOf toRemove

    for i in [index+1..@_datasets.length-1] by 1
      for j in [0..@_datasets[i].iRaw.length-1] by 1
        @_datasets[i].iRaw[j] -= toRemove.vCount
      @_datasets[i].iOffs -= toRemove.iRaw.length

    @_totalIOffs -= toRemove.iRaw.length
    @_totalVOffs -= toRemove.vCount
    @_datasets.splice index, 1

    @uploadGL()

  getDataSet: (id) ->
    for d in @_datasets
      if d.id == id
        return d
    return undefined

  fetchIndexData: ->
    allIData = []
    for d in @_datasets
      allIData = allIData.concat d.iRaw
    return allIData

  fetchVertexData: ->
    allVData = []
    for d in @_datasets
      allVData = allVData.concat d.vRaw
    return allVData

  bindGL: ->
    GL.bindBuffer GL.ARRAY_BUFFER, @_vb
    GL.bindBuffer GL.ELEMENT_ARRAY_BUFFER, @_ib

    for own index, info of @_layout
      @setAttribGL index, info[0], info[1]
    return

  unbindGL: ->
    GL.bindBuffer GL.ARRAY_BUFFER, null
    GL.bindBuffer GL.ELEMENT_ARRAY_BUFFER, null
    return

  setAttribGL: (index, size, offset) ->
    GL.vertexAttribPointer index, size, GL.FLOAT, false, @_stride * 4,
      offset * 4
    return
