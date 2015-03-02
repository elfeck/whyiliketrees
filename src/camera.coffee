class window.Camera

  constructor: ->
    @_cameraPos = new Vec 3, [0.0, 0.0, 0.0]
    # this is needed for x,y rotation axis. icamPos = -camPos
    @_icameraPos = new Vec 3, [0.0, 0.0, 0.0]
    @_cameraDir = new Vec 3, [1.0, 0.0, 1.0]

    @_xRotAxis = new Line @_icameraPos, new Vec 3, [1.0, 0.0, 0.0]
    @_yRotAxis = new Line @_icameraPos, new Vec 3, [0.0, 1.0, 0.0]

    @_viewRotAngle = 0.0
    @_xRotAngle = 0.0
    @_yRotAngle = 0.0

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

    @_speed = 0.05
    @_rotSpeed = 0.0005 * Math.PI

  getVPMat: ->
    @update()
    return @_vpMat

  addToProgram: (program, id = 0) ->
    program.addUniformGL id, "vp_matrix", @getVPMat()
    return

  update: ->
    # update for the rotation axis
    @_icameraPos.setData(@_cameraPos.data()).multScalar(-1.0)

    @_lMat.data()[12] = @_cameraPos.data()[0]
    @_lMat.data()[13] = @_cameraPos.data()[1]
    @_lMat.data()[14] = @_cameraPos.data()[2]

    # rotating camera direction vector
    cc = Math.cos -@_viewRotAngle
    ss = Math.sin -@_viewRotAngle
    rm = new Mat 3, 3 # rotation around y-axis
    rm.toId()
    rm.data()[0] = cc
    rm.data()[2] = -ss
    rm.data()[6] = ss
    rm.data()[8] = cc

    @_cameraDir.setData([0.0, 0.0, 1.0]) # rotate view vector
    @_cameraDir.multMat(rm)
    @_cameraDir.normalize()

    vp = new Mat(4, 4).toId()

    @_yRotAxis.getRotationMatrix @_viewRotAngle, @_rMat
    vp.multFromLeft @_rMat
    @_yRotAxis.getRotationMatrix @_yRotAngle, @_rMat
    vp.multFromLeft @_rMat
    @_xRotAxis.getRotationMatrix @_xRotAngle, @_rMat
    vp.multFromLeft @_rMat

    vp.multFromLeft @_lMat
    vp.multFromLeft @_pMat
    @_vpMat.setTo vp
    return

  doLogic: (delta) ->

    if window.input.keyPressed 65 # a
      @_viewRotAngle -= @_rotSpeed * delta

    if window.input.keyPressed 68 # d
      @_viewRotAngle += @_rotSpeed * delta

    if window.input.keyPressed 87 # w
      @_cameraPos.addVec @_cameraDir.multScalarC(@_speed * delta)

    if window.input.keyPressed 83 # s
      @_cameraPos.addVec @_cameraDir.multScalarC(-@_speed * delta)

    if window.input.keyPressed(32) and not window.input.keyPressed(16)
      @_cameraPos.data()[1] -= @_speed * delta
    if window.input.keyPressed(16) and window.input.keyPressed(32)
      @_cameraPos.data()[1] += @_speed * delta

    if not window.mouseActive
      if window.input.keyPressed 38 #up
        @_xRotAngle -= @_rotSpeed * delta

      if window.input.keyPressed 40 #down
        @_xRotAngle += @_rotSpeed * delta

      if window.input.keyPressed 37 #left
        @_yRotAngle -= @_rotSpeed * delta

      if window.input.keyPressed 39 #right
        @_yRotAngle += @_rotSpeed * delta

      if not (window.input.keyPressed(37) or window.input.keyPressed(39))
        @_yRotAngle += -@_yRotAngle * @_rotSpeed * 4 * delta
        #snapback y-Rot

    else
      if window.input.mouseY >= 0 and
         window.input.mouseY <= window.display.height and
         window.input.mouseDown
        @_xRotAngle -= window.input.mouseDy * 0.01

      if window.input.mouseX >= 0 and
         window.input.mouseX <= window.display.width and
         window.input.mouseDown
        @_yRotAngle += window.input.mouseDx * 0.01

        #snapback for y-Rot
        @_yRotAngle += -@_yRotAngle * 0.1 if not window.input.mouseDown

    @_xRotAngle = Math.max -Math.PI * 0.25, @_xRotAngle
    @_xRotAngle = Math.min Math.PI * 0.25, @_xRotAngle
    @_yRotAngle = Math.max -Math.PI * 0.25, @_yRotAngle
    @_yRotAngle = Math.min Math.PI * 0.25, @_yRotAngle

    @update()
    return

  posToString: ->
    x = -@_cameraPos.data()[0] + ""
    y = -@_cameraPos.data()[1] + ""
    z = -@_cameraPos.data()[2] + ""
    a = (@_viewRotAngle %% 2 * Math.PI) / Math.PI + ""
    b = (@_xRotAngle %% 2 * Math.PI) / Math.PI + ""
    c = (@_yRotAngle %% 2 * Math.PI) / Math.PI + ""

    x = x.substring 0, 6
    y = y.substring 0, 6
    z = z.substring 0, 6
    a = a.substring 0, 3
    b = b.substring 0, 3
    c = c.substring 0, 3

    return "[" + x + ", " + y + ", " + z + " | " + a + " pi, " + b + "pi ," +
      c + " pi]"
