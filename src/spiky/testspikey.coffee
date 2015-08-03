class TestSpiky

  constructor: (@scene) ->
    @uid = getuid()
    @offs = new Vec 3, [3, 0, 3]
    @color = new Vec 3, [1.0, 0.3, 0.3]

    @initGeom()
    @initGfx()

  initGeom: ->
    @baseline = new Line(new Vec(3, [0, 0, 0]), new Vec(3, [0, 0, -1]))
    @basepoly = Polygon.convexFromLine(@baseline, 10,
      [Math.PI * 0.5,
      Math.PI * 0.1,
      Math.PI * 0.1,
      Math.PI * 0.1,
      Math.PI * 0.1,
      Math.PI * 0.1], true)

    @smallpoly = Polygon.regularFromLine(@baseline.shiftBaseC(-5), 2, 6)
    @connpolys = Polygon.pConnectPolygons @basepoly, @smallpoly
    @circle = @basepoly.getMinimalOutcircle()
    @basepoly.getAngles()

  initGfx: ->
    @scene.lineshader.addUniformGL @uid, "offs", @offs
    window.camera.addToProgram @scene.lineshader, @uid

    @scene.fillshader.addUniformGL @uid, "offs", @offs
    @scene.fillshader.addUniformGL @uid, "num_lights", new Vec(1, [2])
    window.camera.addToProgram @scene.fillshader, @uid
    @scene.attenuLight.addToProgram @scene.fillshader, @uid
    pl.addToProgram @scene.fillshader, @uid for pl in @scene.plights

    @fprims = []
    @fprims = @fprims.concat @basepoly.gfxAddFill(@color)
    @fprims = @fprims.concat @smallpoly.gfxAddFill(@color)
    @fprims = @fprims.concat p.gfxAddFill(@color) for p in @connpolys
    @ds = new GeomData @uid, @scene.fillshader, @fprims, GL.TRIANGLES
    @scene.fillGeom.addData @ds

    @lprims = []
    @lprims = @lprims.concat @circle.gfxAddOutline(30, new Vec 3, [0, 1, 0])
    @lds = new GeomData @uid, @scene.lineshader, @lprims, GL.LINES
    @scene.lineGeom.addData @lds

  acc = 0
  doLogic: (delta) ->
    acc += delta * 0.001
    if (not @basepoly.isRegular 0.01) and acc > 5
      @basepoly.regularizeRel(0.01)
      @ds.setModified()
