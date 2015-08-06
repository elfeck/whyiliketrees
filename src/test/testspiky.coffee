class TestSpiky

  constructor: (@scene) ->
    @uid = getuid()
    @offs = new Vec [3, 0, 3]
    @color = new Vec [1.0, 0.3, 0.3]

    @initGeom()
    @initGfx()

  initGeom: ->
    @baseline = new Line(new Vec([0, 0, 0]), new Vec([0, 0, -1]))
    #@basepoly = Polygon.convexFromLine(@baseline, 10,
    #  [Math.PI * 0.5,
    #  Math.PI * 0.1,
    #  Math.PI * 0.1,
    #  Math.PI * 0.1,
    #  Math.PI * 0.1,
    #  Math.PI * 0.1], true)
    @basepoly = Polygon.regularFromLine(@baseline, 10, 6, -1)
    #l = new Line(new Vec([-2, 0, 5], true), new Vec([1, 0, 0], true))
    #@smallpoly = new Polygon [l.base.copy(), l.pointAtDistanceC(4)]
    @smallpoly = Polygon.regularFromLine(@baseline.shiftBaseC(-5), 2, 6)
    #@smallpoly = new Polygon [new Vec([0, 0, 5], true)]
    @connpolys = Polygon.connectPolygons @basepoly, @smallpoly, 1
    @basepoly.reconnect()
    @circle = @basepoly.getMinimalOutcircle()
    @basepoly.getAngles()

  initGfx: ->
    @scene.lineshader.addUniformGL @uid, "offs", @offs
    window.camera.addToProgram @scene.lineshader, @uid

    @scene.fillshader.addUniformGL @uid, "offs", @offs
    @scene.fillshader.addUniformGL @uid, "num_lights", new Vec([2])
    window.camera.addToProgram @scene.fillshader, @uid
    @scene.attenuLight.addToProgram @scene.fillshader, @uid
    pl.addToProgram @scene.fillshader, @uid for pl in @scene.plights

    @basepr = @basepoly.gfxAddFill(@color)
    @smallpr = @smallpoly.gfxAddFill(@color)
    @connpr = []
    @connpr = @connpr.concat p.gfxAddFill @color for p in @connpolys

    @baseds = new GeomData @uid, @scene.fillshader, @basepr, GL.TRIANGLES
    @smallds = new GeomData @uid, @scene.fillshader, @smallpr, GL.TRIANGLES
    @connds = new GeomData @uid, @scene.fillshader, @connpr, GL.TRIANGLES

    @scene.fillGeom.addData @baseds
    @scene.fillGeom.addData @smallds
    @scene.fillGeom.addData @connds

    @lprims = []
    @lprims = @lprims.concat @circle.gfxAddOutline(30, new Vec [0, 1, 0])
    #for p in @fprims
    #  @lprims = @lprims.concat p.dbgAddCentroidNormal()
    #@lds = new GeomData @uid, @scene.lineshader, @lprims, GL.LINES
    #@scene.lineGeom.addData @lds

  acc = 0
  once = true
  onceonce = true
  doLogic: (delta) ->
    acc += delta * 0.001
    if acc > 2 and once
      once = false
      @basepoly.replicatePoint 0
      @basepr = @basepoly.gfxAddFill @color
      @baseds.prims = @basepr
      @baseds.setModified()

      @connpolys = @basepoly.reconnect()
      @connpr = []
      @connpr = @connpr.concat p.gfxAddFill @color for p in @connpolys
      @connds.prims = @connpr
      @connds.setModified()
    if (not @basepoly.isRegular 0.01) and acc > 0 and onceonce
      @basepoly.regularizeAbs(0.001)
      @baseds.setModified()
      @connpolys = @basepoly.reconnect()
      @connpr = []
      @connpr = @connpr.concat p.gfxAddFill @color for p in @connpolys
      @connds.prims = @connpr
      @connds.setModified()
      #onceonce = false
