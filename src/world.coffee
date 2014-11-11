class window.World

  constructor: ->
    @_uid = window.get_uid()
    @globalLights = [
      new PointLight(new Vec(3, [0.0, 40.0, 0.0]), new Vec(1, [80]), 0),
      #new PointLight(new Vec(3, [-50.0, 80.0, 0.0]), new Vec(1, [100.0]), 1)
    ]

    @_program = new ShaderProgram window.worldVert, window.worldFrag
    @_program.initGL()
    gl.addToProgram @_program for gl in @globalLights
    window.camera.addToProgram @_program

    @_geom = new Geom [4, 3, 3]
    @_geom.initGL()

    @vecNet = []
    @generateWorld()


  drawGL: ->
    @_geom.drawGL(@_uid)
    return

  total = 0
  doLogic: (delta) ->
    #@globalLight.lightPos.data()[0] += Math.cos(total* 0.001) * 5
    total += delta
    return

  generateWorld: ->
    size = 10
    total = 20
    offs = -0.5 * total
    for z in [0..total-1] by 1
      for x in [0..total-1] by 1
        @vecNet.push new Vec 4, [(x + offs) * size, @yFunc(x + offs, z + offs),
          (z + offs) * size, 1.0]

    prims = []
    vRaw = []
    iRaw = []
    offs = 0
    for z in [0..total-2] by 1
      for x in [0..total-2] by 1
        prim1 = new Primitive 3
        prim2 = new Primitive 3
        #col = new Vec 3, [z / total, x / total, 0.2]
        col = new Vec 3, [0.7, 0.3, 0.3]

        v1 = [new Vertex, new Vertex, new Vertex]
        v1[0].data.push @vecNet[z * total + x]
        v1[1].data.push @vecNet[z * total + x + 1]
        v1[2].data.push @vecNet[(z + 1) * total + x + 1]

        v2 = [new Vertex, new Vertex, new Vertex]
        v2[0].data.push @vecNet[z * total + x]
        v2[1].data.push @vecNet[(z + 1) * total + x + 1]
        v2[2].data.push @vecNet[(z + 1) * total + x]


        norm1 = Vec.surfaceNormal(
          @vecNet[z * total + x],
          @vecNet[z * total + x + 1],
          @vecNet[(z + 1) * total + x + 1]).normalize()
        norm2 = Vec.surfaceNormal(
          @vecNet[z * total + x],
          @vecNet[(z + 1) * total + x + 1],
          @vecNet[(z + 1) * total + x]).normalize()

        for i in [0..2] by 1
          v1[i].data.push col
          v1[i].data.push norm1
          v2[i].data.push col
          v2[i].data.push norm2

        prim1.vertices = v1
        prim2.vertices = v2
        prims.push prim1
        prims.push prim2

    dataSet = new GeomData @_uid, @_program, prims, true
    @_geom.addData dataSet
    return

  yFunc: (x, z) ->
    y = Math.min 50, (x * x + z * z)
    return y + Math.random() * 10
    #return 0.0
