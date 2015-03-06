class window.Scene

  constructor: ->
    @_lineGeom = new Geom [4, 3]
    @_lineGeom.initGL()
    @_lineShader = new ShaderProgram window.colLineVert, window.colLineFrag
    @_lineShader.initGL()
    @_lineShader.addUniformGL(0, "offs", new Vec(3, [0.0, 0.0, 0.0]))

    @_areaGeom = new Geom [4, 3, 3]
    @_areaGeom.initGL()
    @_areaShader = new ShaderProgram window.colAreaVert, window.colAreaFrag
    @_areaShader.initGL()
    @_areaShader.addUniformGL(0, "offs", new Vec(3, [0.0, 0.0, 0.0]))

    @_pointLight = new PointLight(new Vec(3, [0.0, 30, -10.0]),
      new Vec(1, [100.0], 0, new Vec(3, [1.0, 1.0, 1.0])))
    @_pointLight.addToProgram @_areaShader

    attenu = 0.2
    @_attenuLight = new AttenuationLight new Vec(3, [attenu, attenu, attenu])
    @_attenuLight.addToProgram @_areaShader

    window.camera.addToProgram @_lineShader
    window.camera.addToProgram @_areaShader

    @buildScene()

    @_entities = []

  delegateDrawGL: ->
    #@_lineGeom.updateGL()
    #@_areaGeom.updateGL()
    @_lineGeom.drawGL()
    @_areaGeom.drawGL()
    e.drawGL() for e in @_entities
    return

  delegateDoLogic: (delta) ->
    e.doLogic delta for e in @_entities
    return

  buildScene: ->
    line1 = new Line(new Vec(3, [0.0, 0.0, -5.0]),
      new Vec(3, [0.0, 0.0, 1.0]))
    line2 = new Line(new Vec(3, [0.0, 0, -15.0]),
      new Vec(3, [0.0, 0.0, 1.0]))

    n = 7
    poly1 = Polygon.regularFromLine line1, n, 5
    poly2 = Polygon.regularFromLine line2, n, 5

    poly2.rotateAroundLine line2, Math.PI / n

    outlineCol = new Vec 3, [1.0, 1.0, 1.0]
    areaCol = new Vec 3, [0.9, 0.9, 0.9]
    col1 = new Vec 3, [1, 0.2, 0.4]

    outlines = []
    areas = []

    outlines = outlines.concat poly1.coloredOutline(outlineCol)
    outlines = outlines.concat poly2.coloredOutline(outlineCol)
    #outlines = outlines.concat Polygon.lineconnectPolys poly1, poly2

    areas = areas.concat poly1.coloredArea col1
    areas = areas.concat poly2.coloredArea col1
    areas = areas.concat Polygon.triangleconnectPolys poly1, poly2, col1

    debuglines = []
    for p in areas
      debuglines = debuglines.concat(
        p.centroidNormalLines(5, new Vec(3, [0.0, 1.0, 0.0])))

    #outlines = outlines.concat debuglines

    outlineDS = new GeomData window.get_uid(), @_lineShader,
      outlines, GL.LINES
    areaDS = new GeomData window.get_uid(), @_areaShader,
      areas, GL.TRIANGLES
    @_lineGeom.addData outlineDS
    @_areaGeom.addData areaDS
