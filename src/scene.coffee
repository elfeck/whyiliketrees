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

    @color = new Vec 3, [0.0, 1.0, 0.0]
    @buildScene()

    @_entities = []

  delegateDrawGL: ->
    @_lineGeom.updateGL()
    #@_areaGeom.updateGL()
    @_lineGeom.drawGL()
    @_areaGeom.drawGL()
    return

  total = 0
  delegateDoLogic: (delta) ->
    e.doLogic delta for e in @_entities
    total += delta * 0.001 * Math.PI
    @color.data[0] = 0.5 * (1 + Math.sin(total))
    @color.data[2] = 0.5 * (1 + Math.sin(total))
    @ds1.modified = true
    @ds2.modified = true
    return

  buildScene: ->
    line1 = new Line(new Vec(3, [0.0, 0.0, -5]),
      new Vec(3, [0.0, 1.0, 0.0]))
    prims1 = line1.coloredLineSegC 1.0, 10, @color
    prims2 = line1.coloredLineSegC -1.0, -10, @color
    @ds1 = new GeomData get_uid(), @_lineShader, prims1, GL.LINES
    @ds2 = new GeomData get_uid(), @_lineShader, prims2, GL.LINES
    @_lineGeom.addData @ds1
    @_lineGeom.addData @ds2

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

    outlines = outlines.concat poly1.coloredOutlineC outlineCol
    outlines = outlines.concat poly2.coloredOutlineC outlineCol
    #outlines = outlines.concat Polygon.lineconnectPolys poly1, poly2

    areas = areas.concat poly1.coloredAreaC true, col1
    areas = areas.concat poly2.coloredAreaC false, col1
    areas = areas.concat Polygon.triangleconnectPolysC poly1, poly2, col1

    debuglines = []
    for p in areas
      debuglines = debuglines.concat(
        p.centroidNormalLines(5, debugCol))

    areas = areas.concat @_pLight1.cubeOnPosition()
    areas = areas.concat @_pLight2.cubeOnPosition()
    #debuglines = debuglines.concat @_pLight1.linesFromPosition(debugCol)

    outlineDS = new GeomData get_uid(), @_lineShader, outlines, GL.LINES
    areaDS = new GeomData get_uid(), @_areaShader, areas, GL.TRIANGLES
    debugDS = new GeomData get_uid(), @_lineShader, debuglines, GL.LINES

    @_lineGeom.addData outlineDS
    @_lineGeom.addData debugDS
    @_areaGeom.addData areaDS
