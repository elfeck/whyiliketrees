class window.TheTree

  constructor: () ->
    @_uid = window.get_uid()

    @_geom = new Geom [4, 3, 3]
    @_geom.initGL()

    @_program = new ShaderProgram window.wireVert, window.wireFrag
    @_program.initGL()
    window.camera.addToProgram @_program
    @_program.addUniformGL @_uid, "offs", new Vec(3, [0.0, 10, 0.0])

    @treeLine = []
    @vecNet = []

    @generateTheTreeLine()
    @generateTheTreeVecNet()

    treeLines = []
    for i in [0..@treeLine.length-2] by 1
      treeLines.push []
      treeLines[i].push @treeLine[i]
      treeLines[i].push @treeLine[i + 1]
    dataSet = @generateLineModel treeLines
    @_geom.addData dataSet

  drawGL: ->
    @_geom.drawGL()
    return

  doLogic: (delta) ->
    return

  generateTheTreeLine: ->
    @treeLine = []
    for x in [0..2] by 0.5
      y = - 5 * Math.pow(x-2, 2) + 10
      @treeLine.push(new Vec 4, [x * 5, y, 0.0, 1.0])
    return

  generateTheTreeVecNet: ->
    # generate perin to linevecs
    for i in [0..@treeLine.length-2]
      dir = Vec.subVec @treeLine[i], @treeLine[i + 1]
      console.log dir.data()
    return

  generateLineModel: (lines) ->
    prims = []
    col = new Vec 3, [0.0, 1.0, 0.0]
    norm = new Vec 3, [0.0, 1.0, 0.0]
    for i in [0..lines.length-1]
      verts = [new Vertex, new Vertex]
      verts[0].data.push lines[i][0]
      verts[0].data.push col
      verts[0].data.push norm
      verts[1].data.push lines[i][1]
      verts[1].data.push col
      verts[1].data.push norm
      prim = new Primitive 2
      prim.vertices = verts
      prims.push prim
    dataSet = new GeomData @_uid, @_program, prims, GL.LINES, true
    return dataSet
