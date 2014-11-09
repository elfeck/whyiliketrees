class window.World

  constructor: ->
    @_uid = window.get_uid()
    @_program = new ShaderProgram window.quadVert, window.quadFrag
    @_program.initGL()
    @_program.addUniformGL 0, "vp_matrix", window.camera.getVPMat()

    @_geom = new Geom [4, 4]
    @_geom.initGL()

    @vecNet = []
    @generateWorld()


  drawGL: ->
    @_geom.drawGL(@_uid)
    return

  doLogic: (delta) ->
    return

  generateWorld: ->
    size = 10
    total = 20
    for z in [0..total-1] by 1
      for x in [0..total-1] by 1
        @vecNet.push new Vec 4,
          [x * size, Math.random() * size * 10, z * size, 1.0]

    prims = []
    vRaw = []
    iRaw = []
    offs = 0
    for z in [0..total-2] by 1
      for x in [0..total-2] by 1
        prim1 = new Primitive 3
        prim2 = new Primitive 3
        col = new Vec 4, [z / total, x / total, 0.2, 1.0]

        v1 = [new Vertex, new Vertex, new Vertex]
        v1[0].data.push @vecNet[z * total + x]
        v1[1].data.push @vecNet[z * total + x + 1]
        v1[2].data.push @vecNet[(z + 1) * total + x + 1]

        v2 = [new Vertex, new Vertex, new Vertex]
        v2[0].data.push @vecNet[z * total + x]
        v2[1].data.push @vecNet[(z + 1) * total + x + 1]
        v2[2].data.push @vecNet[(z + 1) * total + x]

        for i in [0..2] by 1
          v1[i].data.push col
          v2[i].data.push col

        prim1.vertices = v1
        prim2.vertices = v2
        prims.push prim1
        prims.push prim2

    dataSet = new GeomData @_uid, @_program, prims, true
    @_geom.addData dataSet
    return
