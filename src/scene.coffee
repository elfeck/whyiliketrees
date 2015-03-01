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

    @_entities = [ ]

  delegateDrawGL: ->
    @_simpleColGeom.updateGL()
    @_simpleColGeom.drawGL()
    e.drawGL() for e in @_entities
    return

  delegateDoLogic: (delta) ->
    e.doLogic delta for e in @_entities
    return

  constructLine: ->
    base = new Vec(3, [10.0, 1.0, 2.0])
    dir = new Vec(3, [0.0, 1.0, 0.0])
    dist = 5
    col = new Vec(3, [1.0, 0.4, 0.4])

    line1 = new Line base, dir
    prim1 = [line1.toColoredLineSeg(0, dist)]
    dataSet = new GeomData window.get_uid(), @_simpleColShader, prim1, GL.LINES
    @_simpleColGeom.addData dataSet

    plane1 = new Plane base, dir
    plane2 = new Plane Vec.addVec(base, Vec.multScalar(dir, dist)), dir

    prim2 = plane1.toColoredRect(5, Math.PI / 8.0, col).concat(
      plane2.toColoredRect(5, 0, col))
    prim3 = plane1.toColoredRect(5, 0, col).concat(
      plane2.toColoredRect(5, 0, col))
    dataSet2 = new GeomData window.get_uid(), @_simpleColShader,
      prim2, GL.TRIANGLES
    @_simpleColGeom.addData dataSet2

    #primCamera = window.camera._yRotAxis.toColoredLineSeg -100, 100
    #dataSet3 = new GeomData window.get_uid(), @_simpleColShader, [primCamera],
    #  GL.LINES
    #@_simpleColGeom.addData dataSet3
