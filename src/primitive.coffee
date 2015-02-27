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


class window.Vertex

  constructor: (@data = []) ->

  fetchVertexData: (vRaw) ->
    v.fetchVertexData vRaw for v in @data
    return
