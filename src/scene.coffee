class window.Scene

  constructor: ->
    @_simpleColGeom = new Geom [4, 3]
    @_simpleColGeom.initGL()

    @_simpleColShader = new ShaderProgram(window.colLineVert,
                                          window.colLineFrag)
    @_simpleColShader.initGL()
    @_simpleColShader.addUniformGL(@_uid, "offs", new Vec(3, [0.0, 0.0, 0.0]))
    window.camera.addToProgram @_simpleColShader

    @buildSceen()

    @_entities = [ ]

  delegateDrawGL: ->
    @_simpleColGeom.updateGL()
    @_simpleColGeom.drawGL()
    e.drawGL() for e in @_entities
    return

  delegateDoLogic: (delta) ->
    e.doLogic delta for e in @_entities
    return

  buildSceen: ->
    line1 = new Line(new Vec(3, [0.0, 0.0, -5.0]), new Vec(3, [0.0, 0.0, 1.0]))
    line2 =
      new Line(new Vec(3, [0.0, 0.0, -10.0]), new Vec(3, [0.0, 0.0, 1.0]))

    poly1 = Polygon.regularFromLine line1, 4, 5
    poly2 = Polygon.regularFromLine line2, 4, 5

    poly2.rotateAroundLine line2, Math.PI / 4.0

    outlineCol = new Vec 3, [1.0, 1.0, 1.0]
    areaCol = new Vec 3, [0.4, 0.4, 0.4]

    outlines = []
    areas = []

    outlines = outlines.concat poly1.coloredOutline(outlineCol)
    outlines = outlines.concat poly2.coloredOutline(outlineCol)

    outlines = outlines.concat Polygon.lineconnectPolys poly1, poly2

    areas = areas.concat poly1.coloredArea(areaCol)
    areas = areas.concat poly2.coloredArea(areaCol)

    outlineDS = new GeomData window.get_uid(), @_simpleColShader,
      outlines, GL.LINES
    areaDS = new GeomData window.get_uid(), @_simpleColShader,
      areas, GL.TRIANGLES
    @_simpleColGeom.addData outlineDS
    @_simpleColGeom.addData areaDS
