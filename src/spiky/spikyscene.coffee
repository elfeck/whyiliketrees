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
    intens = new Vec(1, [35])
    lcol = new Vec(3, [1.0, 1.0, 1.0])
    d = 12
    h = 10
    @attenuLight = new AttenuationLight new Vec(3, [a, a, a])
    @plights = []
    @plights.push(new PointLight(new Vec(3, [d, h, d]), intens, 0, lcol))
    #@plights.push(new PointLight(new Vec(3, [d, h, -d]), intens, 1, lcol))
    #@plights.push(new PointLight(new Vec(3, [-d, h, d]), intens, 2, lcol))
    @plights.push(new PointLight(new Vec(3, [-d, h, -d]), intens, 1, lcol))

    @entities = [
      #new SpikyFloor(this),
      #new Spiky(this, new Vec(3, [0, 0, 0]))
      #new Curly(this)
      #new Growing(this)
      new TestSpiky(this)
    ]

    a = new Vec 3, [1, 1, 0]
    b = new Vec 3, [2, 4, 0]
    c = new Vec 3, [5, 3, 0]
    Circle.fromPoints([a,b,c])

    l1 = new Line(new Vec(3, [0, 0, 0]), new Vec(3, [1, 0, 0]))
    l2 = new Line(new Vec(3, [0, 0, 0]), new Vec(3, [0, 1, 0]))
    Line.getIntersectionLine(l1, l2)

  delegateDrawGL: ->
    @fillGeom.updateGL()
    @fillGeom.drawGL()
    @lineGeom.updateGL()
    @lineGeom.drawGL()
    return

  delegateDoLogic: (delta) ->
    @entities[1].reset() if window.input.keyPressed 82
    e.doLogic delta for e in @entities
    #@entities[0].rotateBaseLine -delta * 0.00005 * Math.PI
    #@entities[1].rotateBaseLine -delta * 0.00005 * Math.PI
    return
