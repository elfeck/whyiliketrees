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
    line = new Line(new Vec(3, [0.0, 0.0, -5.0]), new Vec(3, [0.0, 0.0, 1.0]))
    poly = Polygon.regularFromLine line, 7, 5
    outlineDS = new GeomData window.get_uid(), @_simpleColShader,
      poly.coloredOutline(), GL.LINES
    areaDS = new GeomData window.get_uid(), @_simpleColShader,
      poly.coloredArea(new Vec(3, [0.8, 0.2, 0.2])), GL.TRIANGLES
    @_simpleColGeom.addData outlineDS
    @_simpleColGeom.addData areaDS
