class window.MyTree

  constructor: (@_program, @_debugProgram, @_geom) ->
    @_uid = window.get_uid()
    @dataSets = []

    @vecNets = []
    @dataSet = undefined

    @size = 20
    @offs = new Vec 3, [-@size / 2.0, 20, -@size / 2.0]

    @_program.addUniformGL @_uid, "offs", @offs
    @_debugProgram.addUniformGL @_uid, "offs", @offs

    @generateTree()

  drawGL: ->
    @_geom.drawGL @_uid
    return

  doLogic: (delta) ->
    @handleDebug()
    return

  generateTree: ->
    @vecNets.push []
    col = new Vec 3, [0.1, 0.8, 0.0]
    @vecNets[0].push new Vec(4, [0.0, 0.0, 0.0, 1.0])
    @vecNets[0].push new Vec(4, [@size, 0.0, 0.0, 1.0])
    @vecNets[0].push new Vec(4, [@size, 0.0, @size, 1.0])
    @vecNets[0].push new Vec(4, [0.0, 0.0, @size, 1.0])

    @vecNets[0].push new Vec(4, [0.0, @size * 1, 0.0, 1.0])
    @vecNets[0].push new Vec(4, [@size, @size * 1, 0.0, 1.0])
    @vecNets[0].push new Vec(4, [@size, @size * 1, @size, 1.0])
    @vecNets[0].push new Vec(4, [0.0, @size * 1, @size, 1.0])

    vecs = @vecNets[0]
    prims = [
      @triangleFromVecs(0, 1, 2, col), #bot
      @triangleFromVecs(2, 3, 0, col),
      @triangleFromVecs(4, 5, 6, col), #top
      @triangleFromVecs(6, 7, 4, col),
      @triangleFromVecs(0, 1, 5, col), #front
      @triangleFromVecs(5, 4, 0, col),
      @triangleFromVecs(3, 2, 6, col), #back
      @triangleFromVecs(6, 7, 3, col),
      @triangleFromVecs(1, 2, 6, col), #left
      @triangleFromVecs(6, 5, 1, col),
      @triangleFromVecs(0, 3, 7, col), #right
      @triangleFromVecs(7, 4, 0, col)
    ]
    @dataSets.push new GeomData(@_uid, @_program, prims, GL.TRIANGLES, true)
    @_geom.addData @dataSets[0]
    return

  triangleFromVecs: (v0, v1, v2, col) ->
    vecs = [@vecNets[0][v0], @vecNets[0][v1], @vecNets[0][v2]]
    prim = new Primitive 3
    verts = [new Vertex, new Vertex, new Vertex]
    norm = Vec.surfaceNormal(vecs[0], vecs[1], vecs[2]).normalize()
    console.log norm.data()
    for i in [0..2]
      verts[i].data.push vecs[i]
      verts[i].data.push col
      verts[i].data.push norm
    prim.vertices = verts
    return prim

  handleDebug: ->
    if window.debug and window.wireFrame
      for ds in @dataSets
        ds.program = @_debugProgram
        ds.mode = GL.LINES
    else
      for ds in @dataSets
        ds.program = @_program
        ds.mode = GL.TRIANGLES
    return
