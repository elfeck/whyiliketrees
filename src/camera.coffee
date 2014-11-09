class window.Camera

  constructor: ->
    @_cameraPos = new Vec 3, [0.0, 0.0, 0.0]
    @_cameraDir = new Vec 3, [1.0, 0.0, 1.0]
    @_rotAxis = new Vec 3, [0.0, 1.0, 0.0]
    @_rotAngle = 0.0

    n = 1.0
    f = 1000.0
    ratio = window.display.width / window.display.height
    l = -ratio
    r = ratio
    t = 1
    b = -1

    @_pMat = new Mat(4, 4).toId()    # projection
    @_rMat = new Mat(4, 4).toId()    # rotation
    @_lMat = new Mat(4, 4).toId()    # location
    @_vpMat = new Mat(4, 4).toId()   # projection * view

    @_pMat.setData([
      2.0 * n / (r - l), 0.0, 0.0, 0.0,
      0.0, 2.0 * n / (t - b), 0.0, 0.0,
      (r + l) / (r - l), (t + b) / (t - b), -(f + n) / (f - n), -1,
      0.0, 0.0, -2.0 * n * f / (f - n), 0.0
    ])

    @_speed = 0.5
    @_rotSpeed = 0.01 * Math.PI

  getVPMat: ->
    @update()
    return @_vpMat

  addToProgram: (program, id = 0) ->
    program.addUniformGL id, "vp_matrix", @getVPMat()
    return

  update: ->
    cc = Math.cos @_rotAngle
    ss = Math.sin @_rotAngle
    ic = 1 - cc

    u = @_rotAxis.data()[0]
    v = @_rotAxis.data()[1]
    w = @_rotAxis.data()[2]

    a = -@_cameraPos.data()[0]
    b = -@_cameraPos.data()[1]
    c = -@_cameraPos.data()[2]

    @_rMat.data()[0] = u * u + (v * v + w * w) * cc
    @_rMat.data()[1] = u * v * ic + w * ss
    @_rMat.data()[2] = u * w * ic - v * ss

    @_rMat.data()[4] = u * v * ic - w * ss
    @_rMat.data()[5] = v * v + (u * u + w * w) * cc
    @_rMat.data()[6] = v * w * ic + u * ss

    @_rMat.data()[8] = u * w * ic + v * ss
    @_rMat.data()[9] = v * w * ic - u * ss
    @_rMat.data()[10] = w * w + (u * u + v * v) * cc

    @_rMat.data()[12] = (a * (v * v + w * w) - u * (b * v + c * w)) * ic +
      (b * w - c * v) * ss
    @_rMat.data()[13] = (b * (u * u + w * w) - v * (a * u + c * w)) * ic +
      (c * u - a * w) * ss
    @_rMat.data()[14] = (c * (u * u + v * v) - w * (a * u + b * v)) * ic +
      (a * v - b * u) * ss

    @_lMat.data()[12] = @_cameraPos.data()[0]
    @_lMat.data()[13] = @_cameraPos.data()[1]
    @_lMat.data()[14] = @_cameraPos.data()[2]

    # direction rotation
    rm = new Mat 3, 3
    rm.toId()
    rm.data()[0] = cc
    rm.data()[2] = -ss
    rm.data()[6] = ss
    rm.data()[8] = cc

    @_cameraDir.setData([0.0, 0.0, 1.0])
    @_cameraDir.multMat(rm)
    @_cameraDir.normalize()

    @_vpMat.setTo window.Mat.mult(window.Mat.mult(@_rMat, @_lMat), @_pMat)
    return

  doLogic: (delta) ->

    if window.input.keyPressed 65 # a
      @_rotAngle -= @_rotSpeed

    if window.input.keyPressed 68 # d
      @_rotAngle += @_rotSpeed

    if window.input.keyPressed 87 # w
      @_cameraPos.addVec window.Vec.multScalar(@_cameraDir, @_speed)

    if window.input.keyPressed 83 # s
      @_cameraPos.addVec window.Vec.multScalar(@_cameraDir, @_speed * -1.0)

    if not window.input.keyPressed(16) and window.input.keyPressed(32)
      @_cameraPos.data()[1] -= @_speed * 0.1 * delta
    if window.input.keyPressed(16) and window.input.keyPressed(32)
      @_cameraPos.data()[1] += @_speed * 0.1 * delta

    ###
    if window.input.keyPressed 65
      @_cameraPos.data()[0] += @_speed * delta
    if window.input.keyPressed 68
      @_cameraPos.data()[0] -= @_speed * delta
    if window.input.keyPressed 83
      @_cameraPos.data()[2] -= @_speed * delta
    if window.input.keyPressed 87
      @_cameraPos.data()[2] += @_speed * delta

    if window.input.keyPressed 74
      @_rotAngle += @_rotSpeed
    if window.input.keyPressed 76
      @_rotAngle -= @_rotSpeed
    ###
    @update()
    return

  posToString: ->
    x = @_cameraPos.data()[0] + ""
    y = @_cameraPos.data()[1] + ""
    z = @_cameraPos.data()[2] + ""
    a = (@_rotAngle %% 2 * Math.PI) / Math.PI + ""

    x = x.substring 0, 6
    y = y.substring 0, 6
    z = z.substring 0, 6
    a = a.substring 0, 6

    return "[" + x + ", " + y + ", " + z + " | " + a + " pi]"
