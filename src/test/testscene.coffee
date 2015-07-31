class window.TestScene

  constructor: ->
    console.log("test")
    @debugName = "Test"
    @accTime = 0

    @lineGeom = new Geom [4, 3]
    @lineGeom.initGL()
    @fillGeom = new Geom [4, 3, 3]
    @fillGeom.initGL()

    intens = new Vec(3, [1.0, 1.0, 1.0])
    @pLights = []
    @pLights.push new PointLight(
      new Vec(3, [0.0, 30, 0]), new Vec(1, [55.0]), 0, intens)
    @pLights.push new PointLight(
      new Vec(3, [0, 10, 30]), new Vec(1, [55.0]), 1, intens)

    attenu = 0.3
    @attenuLight = new AttenuationLight new Vec(3, [attenu, attenu, attenu])

    #light debug
    dprims = []
    duid = getuid()
    dshader = window.shaders["fillShader"]
    dshader.addUniformGL duid, "offs", new Vec 3
    dshader.addUniformGL duid, "num_lights", new Vec(1, [@pLights.length])
    window.camera.addToProgram dshader, duid
    @attenuLight.addToProgram dshader, duid
    pl.addToProgram dshader, duid for pl in @pLights

    dprims = dprims.concat pL.dbgAddCube 1 for pL in @pLights
    @dd = new GeomData duid, dshader, dprims, GL.TRIANGLES
    @fillGeom.addData @dd

    @entities = [
      new TestBasic this
      new TestPlatform this
    ]

  delegateDrawGL: ->
    @lineGeom.updateGL()
    @fillGeom.updateGL()
    @lineGeom.drawGL()
    @fillGeom.drawGL()
    return

  delegateDoLogic: (delta) ->
    @accTime += delta
    @pLights[0].lightPos.data[0] = 30 * Math.sin(Math.PI * @accTime * 0.00025)
    @pLights[0].dbgUpdate()
    @dd.setModified()
    e.doLogic delta for e in @entities
    return
