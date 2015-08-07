class window.TestGrowing

  constructor: (@scene) ->
    @uid = getuid()
    @fillshader = @scene.fillshader
    @lineshader = @scene.lineshader

    @color = new Vec [1.0, 0.3, 0.3]
    @offs = Vec.zeros 3

    @n = 5

  initGfx: ->
    @scene.lineshader.addUniformGL @uid, "offs", @offs
    window.camera.addToProgram @lineshader, @uid

    @fillshader.addUniformGL @uid, "offs", @offs
    @fillshader.addUniformGL @uid, "num_lights", new Vec([2])
    window.camera.addToProgram @fillshader, @uid
    @scene.attenuLight.addToProgram @fillshader, @uid
    pl.addToProgram @fillshader, @uid for pl in @scene.plights


class window.Simple extends TestGrowing

  constructor: (scene) ->
    super scene

    @initGeom()
    @initGfx()

  initGeom: ->
    @n = 10
    @h = 15.0
    @step = @h / @n
    points = []
    points.push new Vec([0, 0.01, 0], true)
    points.push new Vec([rndBetween(-1, 1), @step, rndBetween(-1, 1)], true)
    for i in [1..@n]
      points.push @angledRndPoint(points[i])
    @segs = LineSegment.connectPoints points
    lines = []
    lines.push s.getLine() for s in @segs
    @polys = []
    @polys.push Polygon.regularFromLine(new Line(
      new Vec([0, 0.01, 0]),
      new Vec([0, 1, 0])), @widthFun(0), 5)
    for i in [1..lines.length-1]
      @polys.push Polygon.regularFromLine lines[i], @widthFun(i), 5

    @connpolys = []
    for i in [0..@polys.length-2]
      @connpolys = @connpolys.concat(
        Polygon.connectPolygons @polys[i], @polys[i+1])
    return

  widthFun: (x) ->
    yi = 2.5
    a = yi / (@h * @h)
    return a * Math.pow((x - @h), 2)

  angleConstraint: (tangle, p1, p2) ->
    return Vec.angleBetween(p1, p2) < tangle

  angledRndPoint: (p1) ->
    y = p1.y() + @step
    okay = false
    count = 0
    vmax = new Vec [p1.x() + 1, p1.y(), p1.z() + 1]
    tangle = 0.2 * Vec.angleBetween(p1, vmax)
    #console.log "max angle: " + tangle
    while not okay
      x = rndBetween p1.x() - 1, p1.x() + 1
      z = rndBetween p1.z() - 1, p1.z() + 1
      p2 = new Vec [x, y, z], true
      okay = @angleConstraint tangle, p1, p2
      count++
      if count > 100
        okay = true
        console.log "could not find point"
    #console.log "found point after " + count
    return p2

  initGfx: ->
    super()
    lprims = []
    lprims = lprims.concat s.gfxAddLineSeg @color for s in @segs

    pprims = []
    pprims = pprims.concat p.gfxAddFill @color for p in @polys

    cprims = []
    cprims = cprims.concat c.gfxAddFill @color for c in @connpolys

    lds = new GeomData @uid, @lineshader, lprims, GL.LINES
    #@scene.lineGeom.addData lds

    pds = new GeomData @uid, @fillshader, pprims
    #@scene.fillGeom.addData pds

    cds = new GeomData @uid, @fillshader, cprims
    @scene.fillGeom.addData cds
    return

  doLogic: (delta) ->
    return

#
#
# 
class window.Circling extends TestGrowing

  constructor: (scene) ->
    super scene

    @state = 0
    @tacc = 0
    @once = false

    @initGeom()
    @initGfx()

  initGeom: ->
    @baseline = new Line(new Vec([0, 0, 0]), new Vec([0, 0, 1]))
    @basepoly = new Polygon([
      new Vec([-3, 0, 0], true),
      new Vec([3, 0, 0], true)])
    @basepoly.normal = @baseline.dir.copy()

  initGfx: ->
    super()

  updateGfx: ->
    if not @baseds?
      @baseprims = @basepoly.gfxAddFill @color
      @baseds = new GeomData @uid, @fillshader, @baseprims
      @scene.fillGeom.addData @baseds
    else
      @baseprims = @basepoly.gfxAddFill @color
      @baseds.prims = @baseprims
      @baseds.setModified()

  doLogic: (delta) ->
    @tacc += delta * 0.001
    if @tacc > 1
      @tacc = 0
      @state++
      @once = true

    if @state == 1 && @once
      @once = false
      @basepoly.replicatePoint 0
      ldir = @basepoly.points[0].subVecC(@basepoly.points[2])
      @basepoly.points[1].addVec ldir.multScalar -0.1
      @circ = @basepoly.getMinimalOutcircle()

      cprims = @circ.gfxAddOutline 30, Vec.green()
      cds = new GeomData @uid, @lineshader, cprims, GL.LINES
      @scene.lineGeom.addData cds

    if @state == 3 && @once
      @once = false
      @basepoly.replicatePoint 0
      @updateGfx()

    if @state == 1
      @basepoly.movePointsOntoCircleAbs @circ, 0.123, new Vec([1, -1, 0])
      circ = @basepoly.getMinimalOutcircle()
      @updateGfx()

    if @state >= 2
      @basepoly.regularizeAbs 0.1 * Math.PI * 0.001 * delta
      @baseds.setModified()

#
#
# 
class window.Spike extends TestGrowing

  constructor: (scene) ->
    super scene

    @height = 15

    @tacc = 0
    @state = 0

    @initGeom()
    @initGfx()

  initGeom: ->
    @baseline = new Line(new Vec([0, 0.1, 0]), new Vec([0, 1, 0]))

    @basepoly = Polygon.regularFromLine @baseline, @widthFun(@state), @n
    @toppoly = new Polygon([new Vec([0, 0.1, 0], true)])

    @intermPolys = [@basepoly, @toppoly]

    @connpolys = []
    return

  initGfx: ->
    super()

    @baseprims = []
    @baseprims = @baseprims.concat @basepoly.gfxAddFill @color

    @baseds = new GeomData @uid, @fillshader, @baseprims
    @connds = new GeomData @uid, @fillshader, @connprims

    @reconnect()

    @scene.fillGeom.addData @baseds
    @scene.fillGeom.addData @connds
    return

  reconnect: ->
    @connpolys = []
    for i in [0..@intermPolys.length-2]
      @connpolys = @connpolys.concat Polygon.connectPolygons(
        @intermPolys[i], @intermPolys[i+1], -1)
    @connprims = []
    @connprims = @connprims.concat p.gfxAddFill @color for p in @connpolys
    @connds.prims = @connprims
    @connds.setModified()
    return

  angle = (Math.PI * 2) / (20 * 7)
  doLogic: (delta) ->
    @tacc += delta * 0.001
    return if @state > @height
    if @tacc > 1
      @tacc = 0
      @state++

      newpoly = Polygon.regularFromLine(@baseline.shiftBaseC(@state),
        @widthFun(@state), @n)
      console.log @widthFun @state
      newpoly.rotateAroundLine @baseline, angle * @state
      @intermPolys.splice @intermPolys.length-1, 0, newpoly
      @reconnect()

    @toppoly.translatePoints @baseline.dir.multScalarC(delta * 0.001)
    @toppoly.updateConnNormals()

    #for p in @intermPolys
      #p.rotateAroundLine @baseline, -0.001 * delta * Math.PI * 0.025
      #p.updateNormal()
    #for c in @connpolys
      #c.rotateAroundLine @baseline, -0.001 * delta * Math.PI * 0.025
      #c.updateNormal()
    @baseds.setModified()
    @connds.setModified()
    return

  widthFun: (x) ->
    #return 1 + Math.pow(Math.E, -(x-2.1))
    return 0.025 * Math.pow((x - 20), 2)
