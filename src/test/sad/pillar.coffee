class window.Pillar

  constructor: (scene) ->
    @uid = window.getuid()
    @color = new Vec([1, 0, 0])
    @position = new Vec([0, 0.01, 0])

    @initGeom()
    @initShader scene
    @initGfx scene

  initGeom: ->
    @line = new Line(@position.copy(), new Vec([0, 1, 0]))
    @comps = []
    for i in [0..4]
      @comps.push new PillarComponent(@line, 0.01 + i * 2, 5 - i, 2)
    console.log @comps
    return

  initShader: (scene) ->
    window.camera.addToProgram scene.fillShader, @uid
    scene.attenuLight.addToProgram scene.fillShader, @uid
    scene.fillShader.addUniformGL @uid, "num_lights", new Vec([2])
    scene.attenuLight.addToProgram scene.fillShader, @uid
    pL.addToProgram scene.fillShader, @uid for pL in scene.pointLights
    return

  initGfx: (scene) ->
    @prims = []
    for comp in @comps
      @prims = @prims.concat comp.bot.gfxAddFill(@color)
      @prims = @prims.concat comp.top.gfxAddFill(@color)
      @prims = @prims.concat c.gfxAddFill(@color) for c in comp.conn

    @dataSet = new GeomData @uid, scene.fillShader, @prims, GL.TRIANGLES
    scene.fillGeom.addData @dataSet
    return

  doLogic: (delta) ->
    return

class window.PillarComponent

  constructor: (@line, @y, @w, @h) ->
    @bot = Polygon.regularFromLine @line.shiftBaseC(@y), @w, 5
    @top = Polygon.regularFromLine @line.shiftBaseC(@y + @h), @w, 5, -1.0
    @conn = Polygon.connectPolygons @bot, @top
    return
