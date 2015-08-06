class window.SpikyScene

  constructor: ->
    console.log("spiky")
    @debugName = "Spiky"
    window.camera.cameraPos.setData [0, -10, -40]

    @lineGeom = new Geom [4, 3]
    @lineGeom.initGL()
    @fillGeom = new Geom [4, 3, 3]
    @fillGeom.initGL()

    @lineshader = window.shaders["lineShader"]
    @fillshader = window.shaders["fillShader"]

    a = 0.4
    intens = new Vec([35])
    lcol = new Vec([1.0, 1.0, 1.0])
    d = 12
    h = 10
    @attenuLight = new AttenuationLight new Vec([a, a, a])
    @plights = []
    @plights.push(new PointLight(new Vec([d, h, d]), intens, 0, lcol))
    #@plights.push(new PointLight(new Vec([d, h, -d]), intens, 1, lcol))
    #@plights.push(new PointLight(new Vec([-d, h, d]), intens, 2, lcol))
    @plights.push(new PointLight(new Vec([-d, h, -d]), intens, 1, lcol))

    @entities = [
      new SpikyFloor(this),
      #new Spiky(this, new Vec([0, 0, 0]))
      new Curly(this)
      #new Growing(this)
      #new TestSpiky(this)
    ]

  delegateDrawGL: ->
    @fillGeom.dbgReset()
    @lineGeom.dbgReset()

    @fillGeom.updateGL()
    @fillGeom.drawGL()
    @lineGeom.updateGL()
    @lineGeom.drawGL()
    return

  delegateDoLogic: (delta) ->
    #@entities[1].reset() if window.input.keyPressed 82
    e.doLogic delta for e in @entities
    #@entities[0].rotateBaseLine -delta * 0.00005 * Math.PI
    #@entities[1].rotateBaseLine -delta * 0.00005 * Math.PI
    return

  dbgGeomInfo: () ->
    geomInfo = []
    geomInfo.push 0 for i in [0..3]
    geomInfo[0] += @fillGeom.size
    geomInfo[0] += @lineGeom.size
    geomInfo[1] += @fillGeom.dbgNumDraw
    geomInfo[1] += @lineGeom.dbgNumDraw
    geomInfo[2] += @fillGeom.dbgNumUpdates
    geomInfo[2] += @lineGeom.dbgNumUpdates
    geomInfo[3] += @fillGeom.dbgNumUploads
    geomInfo[3] += @lineGeom.dbgNumUploads
    return geomInfo
