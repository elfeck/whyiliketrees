class window.SpikyScene

  constructor: ->
    @debugName = "Spiky"

    @lineGeom = new Geom [4, 3]
    @lineGeom.initGL()
    @fillGeom = new Geom [4, 3, 3]
    @fillGeom.initGL()

    @dshader = window.shaders["fillShader"]

    @attenuLight = new AttenuationLight new Vec(3, [0.3, 0.3, 0.3])

    @pLight = new PointLight(
      new Vec(3, [0, 30, 0]),
      new Vec(1, [40], 0, new Vec(3, [1.0, 1.0, 1.0]))
    )

    @entities = [
      new Spiky this
    ]

  delegateDrawGL: ->
    @fillGeom.updateGL()
    @fillGeom.drawGL()
    return

  delegateDoLogic: (delta) ->
    e.doLogic delta for e in @entities
    return
