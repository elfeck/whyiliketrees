class window.SimpleQuad

  constructor: (@_program, @_debugProgram, @_geom) ->
    @_uid = window.get_uid()
    @dataSets = []

    @vecNets = []
    @dataSet = undefined

    @size = 20
    @offs = new Vec 3, [-@size / 2.0, 20, -@size / 2.0]


    attenuLight = new AttenuationLight(new Vec 3, [0.0, 0.0, 0.0])
    attenuLight.addToProgram(@_program, @_uid)

    @_program.addUniformGL @_uid, "offs", @offs
    @_debugProgram.addUniformGL @_uid, "offs", @offs

    @generateQuad()

  drawGL: ->
    return

  doLogic: (delta) ->
    @handleDebug()
    return

  generateQuad: ->
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
    scol = new Vec 3, [0.0, 0.1, 0.9]
    prims = []
    prims.push @triangleFromVecs(0, 3, 2, col) #bot +
    prims.push @triangleFromVecs(2, 1, 0, col)
    prims.push @triangleFromVecs(4, 5, 6, col) #top
    prims.push @triangleFromVecs(6, 7, 4, col)
    prims.push @triangleFromVecs(0, 1, 5, col) #front
    prims.push @triangleFromVecs(5, 4, 0, col)
    prims.push @triangleFromVecs(3, 7, 6, col) #back +
    prims.push @triangleFromVecs(6, 2, 3, col)
    prims.push @triangleFromVecs(1, 2, 6, col) #left
    prims.push @triangleFromVecs(6, 5, 1, col)
    prims.push @triangleFromVecs(0, 4, 7, col) #right +
    prims.push @triangleFromVecs(7, 3, 0, col)
    @dataSets.push new GeomData(@_uid, @_program, prims, GL.TRIANGLES, true)
    @_geom.addData @dataSets[0]
    return

  triangleFromVecs: (v0, v1, v2, col) ->
    vecs = [@vecNets[0][v0], @vecNets[0][v1], @vecNets[0][v2]]
    prim = new Primitive 3
    verts = [new Vertex, new Vertex, new Vertex]
    norm = Vec.surfaceNormal(vecs[0], vecs[1], vecs[2]).normalize()
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
