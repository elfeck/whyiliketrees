class window.SpikyFloor

  constructor: (scene) ->
    @uid = window.getuid()
    @size = 10
    @num = 20
    @color = new Vec 3, [0.7, 0.7, 0.7]
    @offs = new Vec 3

    @initGeom()
    @initShader scene
    @initGfx scene

  initGeom: ->
    @baseln = new Line(new Vec(3, [0, 0, 0]), new Vec(3, [0, 1, 0]))
    @pbot = Polygon.regularFromLine @baseln, 20, 12, -1
    sln = @baseln.shiftBaseC -2
    @ptop = Polygon.regularFromLine sln, 21, 12
    @pconn = Polygon.pConnectPolygons @pbot, @ptop

  initShader: (scene) ->
    scene.fillshader.addUniformGL @uid, "offs", @offs
    scene.fillshader.addUniformGL @uid, "num_lights", new Vec(1, [4])
    window.camera.addToProgram scene.fillshader, @uid
    scene.attenuLight.addToProgram scene.fillshader, @uid
    pl.addToProgram scene.fillshader, @uid for pl in scene.plights

  initGfx: (scene) ->
    prims = []
    prims = prims.concat @pbot.gfxAddFill(@color)
    prims = prims.concat @ptop.gfxAddFill(@color)
    prims = prims.concat poly.gfxAddFill(@color) for poly in @pconn
    @ds = new GeomData @uid, scene.fillshader, prims, GL.TRIANGLES
    scene.fillGeom.addData @ds

  doLogic: (delta) ->

  rotateBaseLine: (deg) ->
    @pbot.rotateAroundLine @baseln, deg
    @ptop.rotateAroundLine @baseln, deg
    @ds.setModified()
