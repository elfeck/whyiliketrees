class window.Spiky

  constructor: (scene, @offs) ->
    @uid = window.getuid()
    @color = new Vec 3, [1.0, 0.3, 0.3]
    @wcolor = new Vec 3, [1.0, 1.0, 1.0]

    @stepNum = 5
    @length = 20

    @initGeom()
    @initShader scene
    @initGfx scene

  initGeom: ->
    @baseln = new Line new Vec(3, [0.0, 0.0, 0.0]), new Vec(3, [0.0, 1.0, 0.0])
    @steplns = []
    @stepply = []
    @connply = []

    for i in [0..@stepNum - 1]
      @steplns.push @baseln.shiftBaseC(i * (@length / (@stepNum - 1)))
      r = Math.sqrt(i + 1)
      @stepply.push Polygon.regularFromLine(@steplns[i], r, 4, -1.0)
      @stepply[i].rotateAroundLine @baseln, i * (Math.PI / @length)

    for i in [0..@stepply.length - 2]
      @connply =
        @connply.concat Polygon.pConnectPolygons(@stepply[i], @stepply[i + 1],
          -1.0)

    return

  initShader: (scene) ->
    scene.lineshader.addUniformGL @uid, "offs", @offs
    window.camera.addToProgram scene.lineshader, @uid

    scene.fillshader.addUniformGL @uid, "offs", @offs
    scene.fillshader.addUniformGL @uid, "num_lights", new Vec(1, [4])
    window.camera.addToProgram scene.fillshader, @uid
    scene.attenuLight.addToProgram scene.fillshader, @uid
    pl.addToProgram scene.fillshader, @uid for pl in scene.plights
    return

  initGfx: (scene) ->
    lprims = []
    fprims = []
    fprims = fprims.concat @stepply[0].gfxAddFill @color
    fprims = fprims.concat @stepply[@stepply.length - 1].gfxAddFill @color
    for ply in @connply
      fprims = fprims.concat ply.gfxAddFill @color
    for prim in fprims
      lprims = lprims.concat prim.dbgAddCentroidNormal()
    @fds = new GeomData @uid, scene.fillshader, fprims, GL.TRIANGLES
    scene.fillGeom.addData @fds

    @lds = new GeomData @uid, scene.lineshader, lprims, GL.LINES
    #scene.lineGeom.addData @lds


    return

  doLogic: (delta) ->
    return

  rotateBaseLine: (deg) ->
    poly.rotateAroundLine @baseln, deg for poly in @stepply
    @fds.setModified()
