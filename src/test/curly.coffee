class window.Curly

  constructor: (scene) ->
    @uid = getuid()
    @offs = Vec.zeros 3
    @color = new Vec [1.0, 0.3, 0.3]

    @initGeom()
    @initGfx scene

  initGeom: ->
    @points = []
    for i in [2..18] by 0.5
      x = i * Math.sin(i)
      y = i * Math.cos(i)
      @points.push new Vec([x, i, y], true)
    @lineSegs = LineSegment.connectPoints @points
    @polys = []
    for i in [0..@lineSegs.length-1]
      sng = -1.0
      sng = 1.0 if i == 0
      @polys.push Polygon.regularFromLine @lineSegs[i].getLine(), 2, 5, sng
    @connp = []
    for i in [0..@polys.length-2]
      @connp = @connp.concat Polygon.connectPolygons(@polys[i], @polys[i + 1],
        -1.0)

  initGfx: (scene) ->
    scene.lineshader.addUniformGL @uid, "offs", @offs
    window.camera.addToProgram scene.lineshader, @uid

    scene.fillshader.addUniformGL @uid, "offs", @offs
    scene.fillshader.addUniformGL @uid, "num_lights", new Vec([4])
    window.camera.addToProgram scene.fillshader, @uid
    scene.attenuLight.addToProgram scene.fillshader, @uid
    pl.addToProgram scene.fillshader, @uid for pl in scene.plights

    lprims = []
    for i in [0..@lineSegs.length-1]
      lprims = lprims.concat @lineSegs[i].gfxAddLineSeg(@color)

    pprims = []
    pprims = pprims.concat p.gfxAddFill(@color) for p in @polys
    pprims = pprims.concat p.gfxAddFill(@color) for p in @connp
    #lprims = lprims.concat p.dbgAddVertexNormals() for p in pprims

    ds = new GeomData @uid, scene.lineshader, lprims, GL.LINES
    scene.lineGeom.addData ds
    pds = new GeomData @uid, scene.fillshader, pprims, GL.TRIANGLES
    scene.fillGeom.addData pds

  doLogic: (delta) ->
