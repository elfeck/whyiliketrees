class Growing

  constructor: (@scene) ->
    @uid = getuid()
    @offs = Vec.zeros 3
    @color = new Vec [1.0, 0.3, 0.3]

    @initGeom()
    @initGfx()

    @acc = 0
    @state = 0

  initGeom: ->
    @baseline = new Line(new Vec([0, 0.01, 0]), new Vec([0, 1, 0]))
    @basepoly = Polygon.regularFromLine @baseline, 1, 5

    @tp1 = new Vec [0, 4, 0], true
    @top = new Polygon [@tp1]
    @top.normal = new Vec [0, 1, 0]
    @top.normalSign = -1
    @connpolys = Polygon.connectPolygons @basepoly, @top

  initGfx: ->
    @scene.lineshader.addUniformGL @uid, "offs", @offs
    window.camera.addToProgram @scene.lineshader, @uid

    @scene.fillshader.addUniformGL @uid, "offs", @offs
    @scene.fillshader.addUniformGL @uid, "num_lights", new Vec([2])
    window.camera.addToProgram @scene.fillshader, @uid
    @scene.attenuLight.addToProgram @scene.fillshader, @uid
    pl.addToProgram @scene.fillshader, @uid for pl in @scene.plights

    @resetGfx()

  once = true
  odd = true
  onceonce = true
  doLogic: (delta) ->
    @acc += delta * 0.001

    if @state == 1 && once
      once = false
      @top.replicatePoint 0
      @top.points[0].addVec(new Vec [0.01, 0, 0])
      @top.points[1].addVec(new Vec [-0.01, 0, 0])
      @connpolys = @basepoly.reconnect()
      @connpr = []
      @connpr = @connpr.concat p.gfxAddFill @color for p in @connpolys
      @connds.prims = @connpr
      @connds.setModified()
    if @state == 2 && once
      once = false
      @top.replicatePoint 0
      @top.points[0].addVec(@top.points[2].subVecC(@top.points[0]).
        multScalar(0.5))
      @circ = @top.getMinimalOutcircle()
      @toppr = @top.gfxAddFill @color
      @topds = new GeomData @uid, @scene.fillshader, @toppr, GL.TRIANGLES
      @scene.fillGeom.addData @topds

    if @state == 0
      @top.translateAlongNormal 0.0005 * delta
      @connds.setModified()
    if @state == 1
      @top.points[0].addVec new Vec [0.1 * 0.001 * delta, 0, 0]
      @top.points[1].addVec new Vec [0.1 * -0.001 * delta, 0, 0]
      c.updateNormal() for c in @connpolys
      @connds.setModified()
    if @state == 2
      @top.movePointsOntoCircleAbs @circ, new Vec([0, 0, 1]),
        0.001 * delta * 0.1
      @toppr = @top.gfxAddFill @color
      @topds.prims = @toppr
      @topds.setModified()
      @connpolys = @basepoly.reconnect()
      @connpr = []
      @connpr = @connpr.concat p.gfxAddFill @color for p in @connpolys
      @connds.prims = @connpr
      @connds.setModified()
    if @state == 3
      @topds.setModified()
      @connds.setModified()

    if @acc > 5
      once = true
      @state++
      @acc = 0

  resetGfx: ->
    @basepr = @basepoly.gfxAddFill(@color)
    @connpr = []
    @connpr = @connpr.concat(p.gfxAddFill(@color)) for p in @connpolys
    if(@baseds?)
      @baseds.prims = @basepr
      @connds.prims = @connpr
      @baseds.setModified()
      @connds.setModified()
    else
      @baseds = new GeomData @uid, @scene.fillshader, @basepr, GL.TRIANGLES
      @connds = new GeomData @uid, @scene.fillshader, @connpr, GL.TRIANGLES
      @scene.fillGeom.addData @baseds
      @scene.fillGeom.addData @connds
    if(@topds?)
      @topds.prims = []

  reset: ->
    @state = 0
    @acc = 0
    @initGeom()
    @initGfx()
