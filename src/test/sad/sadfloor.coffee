class window.SadFloor

  constructor: (scene) ->
    @uid = window.getuid()
    @color = new Vec([0.5, 0.5, 0.7])
    @size = 100

    @initGeom()
    @initShader scene
    @initGfx scene

  initGeom: ->
    baseLine = new Line(new Vec([0, 0, 0]), new Vec([0, 1, 0]))
    @polyFloor = Polygon.regularFromLine baseLine, @size, 4, -1.0
    return

  initShader: (scene) ->
    window.camera.addToProgram scene.fillShader, @uid
    attenuLight0 = new AttenuationLight new Vec([0, 0, 0])
    attenuLight0.addToProgram scene.fillShader, @uid
    scene.fillShader.addUniformGL @uid, "num_lights", new Vec([2])
    pL.addToProgram scene.fillShader, @uid for pL in scene.pointLights
    return

  initGfx: (scene) ->
    prims = []
    prims = prims.concat @polyFloor.gfxAddFill(@color)
    @dataSet = new GeomData @uid, scene.fillShader, prims, GL.TRIANGLES
    scene.fillGeom.addData @dataSet
    return

  doLogic: (delta) ->
    return
