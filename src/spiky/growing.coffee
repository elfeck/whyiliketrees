class Growing

  constructor: (@scene) ->
    @uid = getuid()
    @offs = new Vec 3
    @color = new Vec 3, [1.0, 0.3, 0.3]

    @initGeom()
    @initGfx()

  initGeom: ->
    @baseline = new Line(new Vec(3, [0, 0, 0]), new Vec(3, [0, 1, 0]))
    @basepoly = Polygon.regularFromLine @baseline, 1, 5

    @top = new Vec 3, [0, 4, 0], true
    @connpolys = Polygon.connectPoint @basepoly, @top

  initGfx: ->
    @scene.lineshader.addUniformGL @uid, "offs", @offs
    window.camera.addToProgram @scene.lineshader, @uid

    @scene.fillshader.addUniformGL @uid, "offs", @offs
    @scene.fillshader.addUniformGL @uid, "num_lights", new Vec(1, [2])
    window.camera.addToProgram @scene.fillshader, @uid
    @scene.attenuLight.addToProgram @scene.fillshader, @uid
    pl.addToProgram @scene.fillshader, @uid for pl in @scene.plights

    @resetGfx()

  doLogic: (delta) ->
    @top.addVec new Vec 3, [0, 0.001 * delta, 0]
    @ds.setModified()

  resetGfx: ->
    @fprims = []
    @fprims = @fprims.concat @basepoly.gfxAddFill(@color)
    @fprims = @fprims.concat(p.gfxAddFill(@color)) for p in @connpolys
    if(@ds?)
      @ds.prims = @fprims
      @ds.setModified()
    else
      @ds = new GeomData @uid, @scene.fillshader, @fprims, GL.TRIANGLES
      @scene.fillGeom.addData @ds

  reset: ->
    @initGeom()
    @initGfx()
