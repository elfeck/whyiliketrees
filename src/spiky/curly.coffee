class Curly

  constructor: (scene) ->
    @uid = getuid()
    @offs = new Vec 3
    @color = new Vec 3, [1.0, 0.3, 0.3]

    @initGeom()
    @initGfx scene

  initGeom: ->
    @lines = []
    @dists = []
    @points = []
    for i in [2..18] by 0.25
      x = i * Math.sin(i)
      y = i * Math.cos(i)
      @points.push new Vec(3, [x, i, y])
    for i in [0..@points.length-2]
      @lines.push Line.fromPoints(@points[i], @points[i + 1])
      @dists.push @points[i].distance(@points[i + 1])
    @polys = []
    for i in [0..@lines.length-1]
      @polys.push Polygon.regularFromLine @lines[i], 2, 5
      #console.log @lines[i]
    #console.log p.data for p in @polys[0].points
    #console.log("----")
    #console.log p.data for p in @polys[1].points
    @connp = []
    for i in [0..@polys.length-2]
      @connp = @connp.concat Polygon.pConnectPolygons(@polys[i], @polys[i + 1])

  initGfx: (scene) ->
    scene.lineshader.addUniformGL @uid, "offs", @offs
    window.camera.addToProgram scene.lineshader, @uid

    scene.fillshader.addUniformGL @uid, "offs", @offs
    scene.fillshader.addUniformGL @uid, "num_lights", new Vec(1, [4])
    window.camera.addToProgram scene.fillshader, @uid
    scene.attenuLight.addToProgram scene.fillshader, @uid
    pl.addToProgram scene.fillshader, @uid for pl in scene.plights

    lprims = []
    for i in [0..@lines.length-1]
      lprims = lprims.concat @lines[i].gfxAddLineSeg(0, @dists[i], @color)
    ds = new GeomData @uid, scene.lineshader, lprims, GL.LINES
    scene.lineGeom.addData ds

    pprims = []
    pprims = pprims.concat p.gfxAddFill(@color) for p in @polys
    pprims = pprims.concat p.gfxAddFill(@color) for p in @connp
    pds = new GeomData @uid, scene.fillshader, pprims, GL.TRIANGLES
    scene.fillGeom.addData pds

  doLogic: (delta) ->
