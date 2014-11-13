class window.World

  constructor: ->
    @_uid = window.get_uid()
    @globalLights = [
      new PointLight(
        new Vec(3, [0.0, 30.0, 0.0]),
        new Vec(1, [80]),
        0,
        new Vec(3, [0.85, 0.85, 0.85])),
      new PointLight(
        new Vec(3, [-100, 80, 0]),
        new Vec(1, [150]),
        1,
        new Vec(3, [0.65, 0.65, 0.65])),
      new PointLight(
        new Vec(3, [100, 80, 0]),
        new Vec(1, [150]),
        2,
        new Vec(3, [0.65, 0.65, 0.65])),
      new PointLight(
        new Vec(3, [0, 80, -100]),
        new Vec(1, [150]),
        3,
        new Vec(3, [0.65, 0.65, 0.65])),
      new PointLight(
        new Vec(3, [0.0, 80, 100]),
        new Vec(1, [150]),
        4,
        new Vec(3, [0.65, 0.65, 0.65])),
      new PointLight(
        new Vec(3, [0.0, 250.0, 0.0]),
        new Vec(1, [300]),
        5,
        new Vec(3, [0.5, 0.5, 0.5]))
    ]
    #@lightAttenu = new window.AttenuationLight new Vec(3, [0.15, 0.15, 0.15])

    @_program = new ShaderProgram window.worldVert, window.worldFrag
    @_debugProgram = new ShaderProgram window.wireVert, window.wireFrag
    @_program.initGL()
    @_debugProgram.initGL()

    gl.addToProgram @_program, 0 for gl in @globalLights
    #@lightAttenu.addToProgram @_program

    window.camera.addToProgram @_program
    window.camera.addToProgram @_debugProgram

    @_geom = new Geom [4, 3, 3]
    @_geom.initGL()

    @vecNets = []
    @dataSets = []
    @generateWorld()

  drawGL: ->
    @_geom.drawGL(@_uid)
    return

  total = 0
  doLogic: (delta) ->
    total += delta
    @handleDebug()
    return

  generateWorld: ->
    size = 10
    total = 50
    offs = -0.5 * total
    @vecNets.push []
    for z in [0..total-1] by 1
      for x in [0..total-1] by 1
        @vecNets[0].push new Vec 4, [(x + offs) * size,
          @yFunc(x + offs, z + offs), (z + offs) * size, 1.0]

    for i in [0..@vecNets.length-1]
      @dataSets.push @vecNetToMesh(@vecNets[i], i + 1)
      @_geom.addData @dataSets[i]
    return

  vecNetToMesh: (vecNet, id) ->
    prims = []
    for z in [0..total-2] by 1
      for x in [0..total-2] by 1
        prim1 = new Primitive 3
        prim2 = new Primitive 3
        col = new Vec 3, [0.7, 0.3, 0.3]

        v1 = [new Vertex, new Vertex, new Vertex]
        v1[0].data.push vecNet[z * total + x]
        v1[1].data.push vecNet[z * total + x + 1]
        v1[2].data.push vecNet[(z + 1) * total + x + 1]

        v2 = [new Vertex, new Vertex, new Vertex]
        v2[0].data.push vecNet[z * total + x]
        v2[1].data.push vecNet[(z + 1) * total + x + 1]
        v2[2].data.push vecNet[(z + 1) * total + x]


        norm1 = Vec.surfaceNormal(
          vecNet[z * total + x],
          vecNet[z * total + x + 1],
          vecNet[(z + 1) * total + x + 1]).normalize()
        norm2 = Vec.surfaceNormal(
          vecNet[z * total + x],
          vecNet[(z + 1) * total + x + 1],
          vecNet[(z + 1) * total + x]).normalize()

        for i in [0..2] by 1
          v1[i].data.push col
          v1[i].data.push norm1
          v2[i].data.push col
          v2[i].data.push norm2

        prim1.vertices = v1
        prim2.vertices = v2
        prims.push prim1
        prims.push prim2

    dataSet = new GeomData id, @_program, prims, GL.TRIANGLES, true
    return dataSet

  yFunc: (x, z) ->
    y = Math.min 50, (x * x + z * z)
    return y + Math.random() * 5
    #return 0.0

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
