class TestPlatform

  constructor: (scene) ->
    @uid = window.getuid()
    @color = new Vec 3, [0.8, 0.2, 0.2]
    @offs = new Vec 3, [10, 0, 0]

    @initGeom()
    @initShader scene
    @initGfx scene

  initShader: (scene) ->
    @shader = window.shaders["fillShader"]
    @shader.addUniformGL @uid, "offs", @offs
    window.camera.addToProgram @shader, @uid
    scene.attenuLight.addToProgram @shader, @uid
    pl.addToProgram @shader, @uid for pl in scene.pLights
    return

  initGeom: ->
    @upperLine = new Line new Vec(3), new Vec(3, [0.0, 1.0, 0.0])
    @lowerLine = @upperLine.shiftBaseC -2.0

    size = 7
    @upperPoly = Polygon.regularFromLine @upperLine, size, 7, -1.0
    @lowerPoly = Polygon.regularFromLine @lowerLine, size - 1, 7
    @lowerPoly.rotateAroundLine @lowerLine, Math.PI / 7.0
    @connPolys = Polygon.pConnectPolygons @upperPoly, @lowerPoly
    return

  initGfx: (scene) ->
    prims = []
    prims = prims.concat @upperPoly.gfxAddFill @color
    prims = prims.concat @lowerPoly.gfxAddFill @color
    prims = prims.concat p.gfxAddFill @color for p in @connPolys
    @ds = new GeomData @uid, @shader, prims, GL.TRIANGLES
    scene.fillGeom.addData @ds

    #dprims = []
    #dprims = dprims.concat pr.dbgAddCentroidNormal() for pr in prims
    #@dds = new GeomData getuid(), @lineShader, dprims, GL.LINES
    #@lineGeom.addData @dds
    return

  doLogic: (delta) ->
    return
