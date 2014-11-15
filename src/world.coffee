class window.World

  constructor: (@_program, @_debugProgram, @_geom) ->
    @_uid = window.get_uid()

    @size = 10
    @total = 50

    @offs = new Vec 3, [0.0, 0.0, 0.0]
    @_program.addUniformGL @_uid, "offs", @offs
    @_debugProgram.addUniformGL @_uid, "offs", @offs

    @vecNets = []
    @dataSets = []
    @generateWorld()

  drawGL: ->
    @_geom.drawGL @_uid
    return

  doLogic: (delta) ->
    @handleDebug()
    return

  generateWorld: ->
    offs = -0.5 * @total
    @vecNets.push []
    for z in [0..@total-1] by 1
      for x in [0..@total-1] by 1
        @vecNets[0].push new Vec 4, [(x + offs) * @size,
          @yFunc(x + offs, z + offs), (z + offs) * @size, 1.0]

    for i in [0..@vecNets.length-1]
      @dataSets.push @vecNetToMesh(@vecNets[i], @_uid)
      @_geom.addData @dataSets[i]
    return

  vecNetToMesh: (vecNet, id) ->
    prims = []
    for z in [0..@total-2] by 1
      for x in [0..@total-2] by 1
        prim1 = new Primitive 3
        prim2 = new Primitive 3
        col = new Vec 3, [0.7, 0.3, 0.3]

        v1 = [new Vertex, new Vertex, new Vertex]
        v1[0].data.push vecNet[z * @total + x]
        v1[1].data.push vecNet[z * @total + x + 1]
        v1[2].data.push vecNet[(z + 1) * @total + x + 1]

        v2 = [new Vertex, new Vertex, new Vertex]
        v2[0].data.push vecNet[z * @total + x]
        v2[1].data.push vecNet[(z + 1) * @total + x + 1]
        v2[2].data.push vecNet[(z + 1) * @total + x]


        norm1 = Vec.surfaceNormal(
          vecNet[z * @total + x],
          vecNet[z * @total + x + 1],
          vecNet[(z + 1) * @total + x + 1]).normalize()
        norm2 = Vec.surfaceNormal(
          vecNet[z * @total + x],
          vecNet[(z + 1) * @total + x + 1],
          vecNet[(z + 1) * @total + x]).normalize()

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
