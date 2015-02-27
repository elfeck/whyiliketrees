class window.Scene

  constructor: ->
    @_lineGeom = new Geom [4, 3]
    @_lineGeom.initGL()

    @_lineShader = new ShaderProgram(window.colLineVert, window.colLineFrag)
    @_lineShader.initGL()
    @_lineShader.addUniformGL(@_uid, "offs", new Vec(3, [0.0, 0.0, 0.0]))
    window.camera.addToProgram @_lineShader

    @constructLine()
    @constructPlane()

    @_entities = [ ]

  delegateDrawGL: ->
    @_lineGeom.drawGL()
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

    dataSet = new GeomData 1, @_lineShader, prim1.concat(prim2), GL.LINES
    @_lineGeom.addData dataSet

  constructPlane: ->
    plane = new Plane(new Vec(3, [0, 1, 0]), new Vec(3, [0, 1, 0]))
    prims = plane.toColoredLineSegs 10, 10
    dataSet = new GeomData 2, @_lineShader, prims, GL.LINES
    @_lineGeom.addData dataSet
