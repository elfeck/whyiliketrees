class window.Camera

  constructor: ->
    @_cameraPos = [0.0, 0.0, 0.0]
    @_rotAxis = [0.0, 1.0, 0.0]
    @_rotAngle = 0.0

    n = 1.0
    f = 100.0

    l = -1.5
    r = 1.5
    t = 1
    b = -1

    @_pMat = new Mat 4, 4    # projection
    @_rMat = new Mat 4, 4    # rotation
    @_lMat = new Mat 4, 4    # location
    @_pvMat = new Mat 4, 4   # projection * view

    @_pMat.data = [
      2.0 * n / (r - l), 0.0, 0.0, 0.0,
      0.0, 2.0 * n / (t - b), 0.0, 0.0,
      (r + l) / (r - l), (t + b) / (t - b), -(f + n) / (f - n), -1,
      0.0, 0.0, -2.0 * n * f / (f - n), 0.0
    ]

    @_rMat.toId()
    @_lMat.toId()
    @_pvMat.toId()

    @_speed = 0.01
    @_rotSpeed = 0.01 * Math.PI

  addPVToProgram: (program) ->
    program.addUniformGL "pv_matrix", @_pvMat

  update: ->
    cc = Math.cos @_rotAngle
    ss = Math.sin @_rotAngle
    ic = 1 - cc

    u = @_rotAxis[0]
    v = @_rotAxis[1]
    w = @_rotAxis[2]

    a = -@_cameraPos[0]
    b = -@_cameraPos[1]
    c = -@_cameraPos[2]

    @_rMat.data[0] = u * u + (v * v + w * w) * cc
    @_rMat.data[1] = u * v * ic + w * ss
    @_rMat.data[2] = u * w * ic - v * ss

    @_rMat.data[4] = u * v * ic - w * ss
    @_rMat.data[5] = v * v + (u * u + w * w) * cc
    @_rMat.data[6] = v * w * ic + u * ss

    @_rMat.data[8] = u * w * ic + v * ss
    @_rMat.data[9] = v * w * ic - u * ss
    @_rMat.data[10] = w * w + (u * u + v * v) * cc

    @_rMat.data[12] = (a * (v * v + w * w) - u * (b * v + c * w)) * ic +
      (b * w - c * v) * ss
    @_rMat.data[13] = (b * (u * u + w * w) - v * (a * u + c * w)) * ic +
      (c * u - a * w) * ss
    @_rMat.data[14] = (c * (u * u + v * v) - w * (a * u + b * v)) * ic +
      (a * v - b * u) * ss

    @_lMat.data[12] = @_cameraPos[0]
    @_lMat.data[13] = @_cameraPos[1]
    @_lMat.data[14] = @_cameraPos[2]

    @_pvMat.setTo window.Mat.mult(window.Mat.mult(@_rMat, @_lMat), @_pMat)

  doLogic: (delta) ->
    if window.input.keyPressed 65
      @_cameraPos[0] += @_speed * delta
    if window.input.keyPressed 68
      @_cameraPos[0] -= @_speed * delta
    if window.input.keyPressed 83
      @_cameraPos[2] -= @_speed * delta
    if window.input.keyPressed 87
      @_cameraPos[2] += @_speed * delta
    if not window.input.keyPressed(16) and window.input.keyPressed(32)
      @_cameraPos[1] -= @_speed * delta
    if window.input.keyPressed(16) and window.input.keyPressed(32)
      @_cameraPos[1] += @_speed * delta

    if window.input.keyPressed 74
      @_rotAngle += @_rotSpeed
    if window.input.keyPressed 76
      @_rotAngle -= @_rotSpeed

    @update()
