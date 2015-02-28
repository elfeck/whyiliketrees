class window.Scene

  constructor: ->
    @_simpleColGeom = new Geom [4, 3]
    @_simpleColGeom.initGL()

    @_simpleColShader = new ShaderProgram(window.colLineVert,
                                          window.colLineFrag)
    @_simpleColShader.initGL()
    @_simpleColShader.addUniformGL(@_uid, "offs", new Vec(3, [0.0, 0.0, 0.0]))
    window.camera.addToProgram @_simpleColShader

    @constructLine()
    @constructPlane()

    @_entities = [ ]

  delegateDrawGL: ->
    @_simpleColGeom.drawGL()
    e.drawGL() for e in @_entities
    return

  delegateDoLogic: (delta) ->
    e.doLogic delta for e in @_entities
    return

  constructLine: ->
    line1 = new Line(
      new Vec(3, [5.0, 0.0, 0.0]),
      new Vec(3, [0.0, 1.0, 0.0]))

    line2 = new Line(
      new Vec(3, [-5.0, 0.0, 0.0]),
      new Vec(3, [0.0, 1.0, 0.0]))

    prim1 = [line1.toColoredLineSeg(0, 2), line1.toColoredLineSeg(3, 4)]
    prim2 = [line2.toColoredLineSeg(0, 2), line2.toColoredLineSeg(3, 4)]

    dataSet = new GeomData 1, @_simpleColShader, prim1.concat(prim2), GL.LINES
    @_simpleColGeom.addData dataSet

  constructPlane: ->
    plane = new Plane(new Vec(3, [0, 1, 0]), new Vec(3, [0, 1, 0]))

    prims = plane.toColoredLineSegs 10, 10
    dataSet = new GeomData 2, @_simpleColShader, prims, GL.LINES
    @_simpleColGeom.addData dataSet

    prims_r = plane.toColoredRect 10, new Vec(3, [1.0, 0.0, 0.0])
    dataSet_r = new GeomData 3, @_simpleColShader, prims_r, GL.TRIANGLES
    @_simpleColGeom.addData dataSet_r
