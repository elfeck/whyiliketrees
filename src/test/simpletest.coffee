class window.SimpleTest

  constructor: (@scene) ->
    @uid = getuid()
    @offs = new Vec [0, 10, 0]
    @color = new Vec [1.0, 0.3, 0.3]

    @initGeom()
    @initGfx()

  initGeom: ->
    @base = new Vec([5, 2, 1])
    @baseline = new Line(@base, new Vec([0, 0, 1]))
    @basepoly = Polygon.regularFromLine(@baseline, 5, 6, -1)
    @rpoly = Polygon.regularFromLine(@baseline, 5, 6, -1)

    @basepoly.scalePoints 0.5

  initGfx: ->
    @scene.lineshader.addUniformGL @uid, "offs", @offs
    window.camera.addToProgram @scene.lineshader, @uid

    @scene.fillshader.addUniformGL @uid, "offs", @offs
    @scene.fillshader.addUniformGL @uid, "num_lights", new Vec([2])
    window.camera.addToProgram @scene.fillshader, @uid
    @scene.attenuLight.addToProgram @scene.fillshader, @uid
    pl.addToProgram @scene.fillshader, @uid for pl in @scene.plights

    @lshader = window.shaders["lineShader"]
    @lshader.addUniformGL @uid, "offs", @offs
    window.camera.addToProgram @lshader, @uid

    @basepr = @basepoly.gfxAddFill(@color)
    @basepr = @basepr.concat @rpoly.gfxAddFill(Vec.green())
    @baseds = new GeomData @uid, @scene.fillshader, @basepr, GL.TRIANGLES
    @scene.fillGeom.addData @baseds

    #@lds = new GeomData @uid, @scene.lineshader, @linepr, GL.LINES
    #@scene.lineGeom.addData @lds

  doLogic: (delta) ->
