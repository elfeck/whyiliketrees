class window.Primitive

  constructor: (@_vCount) ->
    @vertices = []

  fetchVertexData: (vRaw) ->
    v.fetchVertexData vRaw for v in @vertices
    return

  fetchIndexData: (iRaw, offs) ->
    iRaw.push(i + offs) for i in [0..@_vCount-1] by 1
    return offs + @_vCount


class window.Vertex

  constructor: () ->
    @data = []

  fetchVertexData: (vRaw) ->
    for v in @data
      vRaw.push val for val in v.data
    return
