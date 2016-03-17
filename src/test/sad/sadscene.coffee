class window.SadScene

  constructor: ->
    @debugName = "Sad"

    @fillGeom = new Geom [4, 3, 3]
    @fillGeom.initGL()
    @fillShader = window.shaders["fillShader"]
    window.camera.cameraPos.setData [0, -5, -10]

    a = 0.1
    intens = new Vec [70]
    lcol = new Vec [1, 1, 1]
    d = 12
    h = 25
    @attenuLight = new AttenuationLight new Vec([a, a, a])
    @pointLights = [
      new PointLight(new Vec([d, h, 0]), intens, 0, lcol),
      new PointLight(new Vec([-d, h, 0]), intens, 1, lcol),
    ]

    @entities = [
      new SadFloor(this),
      new Pillar(this)]

    uid = window.getuid()
    lightPrims = []
    lightPrims = lightPrims.concat pL.dbgAddCube 1 for pL in @pointLights
    @fillShader.addUniformGL uid, "num_lights", new Vec([@pointLights.length])
    dataSet = new GeomData uid, @fillShader, lightPrims, GL.TRIANGLES
    @fillGeom.addData dataSet

  delegateDrawGL: ->
    @fillGeom.dbgReset()
    @fillGeom.updateGL()
    @fillGeom.drawGL()
    return

  delegateDoLogic: (delta) ->
    e.doLogic for e in @entities
    return

  dbgGeomInfo: ->
    geomInfo = [0, 0, 0, 0]
    geomInfo[0] += @fillGeom.size
    geomInfo[1] += @fillGeom.dbgNumDraw
    geomInfo[2] += @fillGeom.dbgNumUpdates
    geomInfo[3] += @fillGeom.dbgNumUploads
    return geomInfo
