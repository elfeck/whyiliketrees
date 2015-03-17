class window.TestScene

  constructor: ->
    @debugName = "Test"
    @lineGeom = new Geom [4, 3]
    @lineGeom.initGL()
    @lineShader = new ShaderProgram window.colLineVert, window.colLineFrag
    @lineShader.initGL()
    @lineShader.addUniformGL(0, "offs", new Vec(3, [0.0, 0.0, 0.0]))

    @fillGeom = new Geom [4, 3, 3]
    @fillGeom.initGL()
    @fillShader = new ShaderProgram window.colFillVert, window.colFillFrag
    @fillShader.initGL()
    @fillShader.addUniformGL(0, "offs", new Vec(3, [0.0, 0.0, 0.0]))

    @pLight1 = new PointLight(
      new Vec(3, [0.0, 10, -10.0]),
      new Vec(1, [50.0]),
      0,
      new Vec(3, [1.0, 1.0, 1.0]))
    @pLight2 = new PointLight(
      new Vec(3, [10, 10, 0]),
      new Vec(1, [30]),
      1,
      new Vec(3, [1.0, 1.0, 1.0]))
    @pLight1.addToProgram @fillShader
    #@pLight2.addToProgram @fillShader

    attenu = 0.3
    @attenuLight = new AttenuationLight new Vec(3, [attenu, attenu, attenu])
    @attenuLight.addToProgram @fillShader

    window.camera.addToProgram @lineShader
    window.camera.addToProgram @fillShader

    @buildScene1()

    @entities = []

  delegateDrawGL: ->
    @lineGeom.updateGL()
    @fillGeom.updateGL()
    @lineGeom.drawGL()
    @fillGeom.drawGL()
    return

  accTime = 0
  delegateDoLogic: (delta) ->
    accTime += delta

    @poly1.rotateAroundLine @pline1, Math.PI * delta * 0.0001
    @poly2.rotateAroundLine @pline1, Math.PI * delta * 0.0001

    @pLight1.lightPos.data[0] = 10 * Math.sin(Math.PI * accTime * 0.0005)
    @pLight1.dbgUpdate()

    @dd.setModified()

    @ds4.setModified()
    @ds5.setModified()
    @ds6.setModified()
    return

  buildScene1: ->
    @color2 = new Vec 3, [1.0, 0.3, 0.3]

    @pline1 = new Line(
      new Vec(3, [0.0, 0.0, -4]),
      new Vec(3, [0.0, 0.0, 1.0]))
    @poly1 = Polygon.regularFromLine @pline1, 0.75, 3, -1.0

    prims = @poly1.gfxAddFill @color2
    @ds4 = new GeomData getuid(), @fillShader, prims, GL.TRIANGLES

    @pline2 = @pline1.shiftBaseC -5
    @poly2 = Polygon.regularFromLine @pline2, 2, 7
    @poly2.rotateAroundLine @pline2, Math.PI / 7.0

    prims = @poly2.gfxAddFill @color2
    @ds5 = new GeomData getuid(), @fillShader, prims, GL.TRIANGLES

    @polys = Polygon.pConnectPolygons @poly1, @poly2
    point1 = new Vec 3, [-1, 0.0, -4], true
    point2 = new Vec 3, [1, 0.0, -4], true
    prims = []
    prims = prims.concat p.gfxAddFill @color2 for p in @polys
    @ds6 = new GeomData getuid(), @fillShader, prims, GL.TRIANGLES

    dprims = @pLight1.dbgAddCube()
    @dd = new GeomData getuid(), @fillShader, dprims, GL.TRIANGLES
    @fillGeom.addData @dd

    @fillGeom.addData @ds4
    @fillGeom.addData @ds5
    @fillGeom.addData @ds6
