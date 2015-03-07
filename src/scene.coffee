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

    @_pLight1 = new PointLight(
      new Vec(3, [0.0, 30, -10.0]),
      new Vec(1, [50.0]),
      0,
      new Vec(3, [1.0, 1.0, 1.0]))
    @_pLight2 = new PointLight(
      new Vec(3, [10, 10, 0]),
      new Vec(1, [30]),
      1,
      new Vec(3, [1.0, 1.0, 1.0]))
    @_pLight1.addToProgram @_areaShader
    @_pLight2.addToProgram @_areaShader

    attenu = 0.2
    @_attenuLight = new AttenuationLight new Vec(3, [attenu, attenu, attenu])
    @_attenuLight.addToProgram @_areaShader

    window.camera.addToProgram @_lineShader
    window.camera.addToProgram @_areaShader

    @buildSceneOld()

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


  buildSceneOld: ->
    line1 = new Line(new Vec(3, [0.0, 0.0, -5.0]),
      new Vec(3, [0.0, 0.0, 1.0]))
    line2 = new Line(new Vec(3, [0.0, 0, -15.0]),
      new Vec(3, [0.0, 0.0, 1.0]))

    n = 7
    poly1 = Polygon.regularFromLine line1, n, 5
    poly2 = Polygon.regularFromLine line2, n, 5

    poly2.rotateAroundLine line2, Math.PI / n

    outlineCol = new Vec 3, [1.0, 1.0, 1.0]
    debugCol = new Vec 3, [0.0, 1.0, 0.0]
    col1 = new Vec 3, [1, 0.2, 0.4]

    outlines = []
    areas = []

    #outlines = outlines.concat poly1.coloredOutline(outlineCol)
    #outlines = outlines.concat poly2.coloredOutline(outlineCol)
    #outlines = outlines.concat Polygon.lineconnectPolys poly1, poly2

    areas = areas.concat poly1.coloredAreaC true, col1
    areas = areas.concat poly2.coloredAreaC false, col1
    areas = areas.concat Polygon.triangleconnectPolysC poly1, poly2, col1

    debuglines = []
    for p in areas
      debuglines = debuglines.concat(
        p.centroidNormalLines(5, debugCol))
    #outlines = outlines.concat debuglines

    areas = areas.concat @_pLight1.cubeOnPosition()
    areas = areas.concat @_pLight2.cubeOnPosition()
    #outlines = outlines.concat @_pLight1.linesFromPosition(debugCol)

    outlineDS = new GeomData window.get_uid(), @_lineShader,
      outlines, GL.LINES
    areaDS = new GeomData window.get_uid(), @_areaShader,
      areas, GL.TRIANGLES
    @_lineGeom.addData outlineDS
    @_areaGeom.addData areaDS
