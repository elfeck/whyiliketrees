class window.Scene

  constructor: ->
    @_lineGeom = new Geom [4, 3]
    @_lineGeom.initGL()
    @_lineShader = new ShaderProgram window.colLineVert, window.colLineFrag
    @_lineShader.initGL()
    @_lineShader.addUniformGL(0, "offs", new Vec(3, [0.0, 0.0, 0.0]))

    @_fillGeom = new Geom [4, 3, 3]
    @_fillGeom.initGL()
    @_fillShader = new ShaderProgram window.colFillVert, window.colFillFrag
    @_fillShader.initGL()
    @_fillShader.addUniformGL(0, "offs", new Vec(3, [0.0, 0.0, 0.0]))

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
    @_pLight1.addToProgram @_fillShader
    @_pLight2.addToProgram @_fillShader

    attenu = 0.2
    @_attenuLight = new AttenuationLight new Vec(3, [attenu, attenu, attenu])
    @_attenuLight.addToProgram @_fillShader

    window.camera.addToProgram @_lineShader
    window.camera.addToProgram @_fillShader

    @buildScene()

    @_entities = []

  delegateDrawGL: ->
    @_lineGeom.updateGL()
    @_fillGeom.updateGL()
    @_lineGeom.drawGL()
    @_fillGeom.drawGL()
    return

  accTime = 0
  delegateDoLogic: (delta) ->
    accTime += delta

    @line.dir.data[0] = Math.sin(Math.PI * accTime * 0.0001)
    @line.dir.data[1] = Math.cos(Math.PI * accTime * 0.0001)
    @line.gfxUpdate()
    @ds1.setModified()

    @poly1.rotateAroundLine @pline1, Math.PI * delta * 0.0001
    @poly1.gfxUpdate()
    @ds2.setModified()

    @poly2.rotateAroundLine @pline1, Math.PI * delta * 0.0001
    @poly2.gfxUpdate()
    @ds3.setModified()
    @ds4.setModified()
    @ds5.setModified()
    return

  buildScene: ->
    @color1 = new Vec 3, [0.4, 0.8, 0.2]
    @color2 = new Vec 3, [0.8, 0.2, 0.4]
    @line = new Line(new Vec(3, [0.0, 0.0, -5]), new Vec(3, [0.0, 1.0, 0.0]))
    prims = @line.gfxAddLineSeg 1, 10, @color1
    prims = prims.concat @line.gfxAddLineSeg -1, -10, @color1
    @ds1 = new GeomData get_uid(), @_lineShader, prims, GL.LINES

    @pline1 = new Line(
      new Vec(3, [0.0, 0.0, -4]),
      new Vec(3, [0.0, 0.0, 1.0]))
    @poly1 = Polygon.regularFromLine @pline1, 6, 5
    prims = @poly1.gfxAddOutline @color1
    @ds2 = new GeomData get_uid(), @_lineShader, prims, GL.LINES

    prims = @poly1.gfxAddFill @color1
    @ds4 = new GeomData get_uid(), @_lineShader, prims, GL.TRIANGLES

    @pline2 = @pline1.shiftBaseC -5
    @poly2 = Polygon.regularFromLine @pline2, 6, 5
    prims = @poly2.gfxAddOutline @color2
    @ds3 = new GeomData get_uid(), @_lineShader, prims, GL.LINES

    prims = @poly2.gfxAddFill @color2
    @ds5 = new GeomData get_uid(), @_lineShader, prims, GL.TRIANGLES

    Polygon.connect @poly1, @poly2

    #@_lineGeom.addData @ds1
    @_lineGeom.addData @ds2
    @_lineGeom.addData @ds3
    @_fillGeom.addData @ds4
    @_fillGeom.addData @ds5
