class window.Camera

  constructor: ->
    @cameraPos = Vec.zeros 3
    # this is needed for x,y rotation axis. icamPos = -camPos
    @icameraPos = new Vec [0.0, 0.0, 0.0]
    @cameraDir = new Vec [1.0, 0.0, 1.0]

    @xRotAxis = new Line @icameraPos, new Vec([1.0, 0.0, 0.0]), true
    @yRotAxis = new Line @icameraPos, new Vec([0.0, 1.0, 0.0]), true

    @viewRotAngle = 0.0
    @xRotAngle = 0.0
    @yRotAngle = 0.0

    n = 1.0
    f = 1000.0
    ratio = window.display.width / window.display.height
    l = -ratio
    r = ratio
    t = 1
    b = -1

    @pMat = new Mat(4, 4).toId()    # projection
    @rMat = new Mat(4, 4).toId()    # rotation
    @lMat = new Mat(4, 4).toId()    # location
    @vpMat = new Mat(4, 4).toId()   # projection * view

    @pMat.setData([
      2.0 * n / (r - l), 0.0, 0.0, 0.0,
      0.0, 2.0 * n / (t - b), 0.0, 0.0,
      (r + l) / (r - l), (t + b) / (t - b), -(f + n) / (f - n), -1,
      0.0, 0.0, -2.0 * n * f / (f - n), 0.0
    ])

    @speed = 0.025
    @rotSpeed = 0.0005 * Math.PI

  getVPMat: ->
    @update()
    return @vpMat

  addToProgram: (program, id = 0) ->
    program.addUniformGL id, "vp_matrix", @getVPMat()
    return

  update: ->
    # update for the rotation axis
    @icameraPos.setData(@cameraPos.data).multScalar(-1.0)

    @lMat.data[12] = @cameraPos.data[0]
    @lMat.data[13] = @cameraPos.data[1]
    @lMat.data[14] = @cameraPos.data[2]

    # rotating camera direction vector
    cc = Math.cos -@viewRotAngle
    ss = Math.sin -@viewRotAngle
    rm = new Mat 3, 3 # rotation around y-axis
    rm.toId()
    rm.data[0] = cc
    rm.data[2] = -ss
    rm.data[6] = ss
    rm.data[8] = cc

    @cameraDir.setData([0.0, 0.0, 1.0]) # rotate view vector
    @cameraDir.multMat(rm)
    @cameraDir.normalize()

    vp = new Mat(4, 4).toId()

    @yRotAxis.getRotationMatrix @viewRotAngle, @rMat
    vp.multFromLeft @rMat
    @yRotAxis.getRotationMatrix @yRotAngle, @rMat
    vp.multFromLeft @rMat
    @xRotAxis.getRotationMatrix @xRotAngle, @rMat
    vp.multFromLeft @rMat

    vp.multFromLeft @lMat
    vp.multFromLeft @pMat
    @vpMat.setTo vp
    return

  doLogic: (delta) ->

    if window.input.keyPressed 65 # a
      @viewRotAngle -= @rotSpeed * delta

    if window.input.keyPressed 68 # d
      @viewRotAngle += @rotSpeed * delta

    if window.input.keyPressed 87 # w
      @cameraPos.addVec @cameraDir.multScalarC(@speed * delta)

    if window.input.keyPressed 83 # s
      @cameraPos.addVec @cameraDir.multScalarC(-@speed * delta)

    if window.input.keyPressed(32) and not window.input.keyPressed(16)
      @cameraPos.data[1] -= @speed * delta
    if window.input.keyPressed(16) and window.input.keyPressed(32)
      @cameraPos.data[1] += @speed * delta

    if not window.mouseActive
      if window.input.keyPressed 38 #up
        @xRotAngle -= @rotSpeed * delta

      if window.input.keyPressed 40 #down
        @xRotAngle += @rotSpeed * delta

      if window.input.keyPressed 37 #left
        @yRotAngle -= @rotSpeed * delta

      if window.input.keyPressed 39 #right
        @yRotAngle += @rotSpeed * delta

      if not (window.input.keyPressed(37) or window.input.keyPressed(39))
        @yRotAngle += -@yRotAngle * @rotSpeed * 4 * delta
        #snapback y-Rot

    else
      if window.input.mouseY >= 0 and
         window.input.mouseY <= window.display.height and
         window.input.mouseDown
        @xRotAngle -= window.input.mouseDy * 0.01

      if window.input.mouseX >= 0 and
         window.input.mouseX <= window.display.width and
         window.input.mouseDown
        @yRotAngle += window.input.mouseDx * 0.01

        #snapback for y-Rot
        @yRotAngle += -@yRotAngle * 0.1 if not window.input.mouseDown

    @xRotAngle = Math.max -Math.PI * 0.25, @xRotAngle
    @xRotAngle = Math.min Math.PI * 0.25, @xRotAngle
    @yRotAngle = Math.max -Math.PI * 0.25, @yRotAngle
    @yRotAngle = Math.min Math.PI * 0.25, @yRotAngle

    @update()
    return

  posToString: ->
    x = -@cameraPos.data[0] + ""
    y = -@cameraPos.data[1] + ""
    z = -@cameraPos.data[2] + ""
    a = (@viewRotAngle %% 2 * Math.PI) / Math.PI + ""
    b = (@xRotAngle %% 2 * Math.PI) / Math.PI + ""
    c = (@yRotAngle %% 2 * Math.PI) / Math.PI + ""
    b10 = Math.log(10)
    lx = Math.max 0, Math.floor(Math.log(Math.abs(x + 10)) / b10)
    ly = Math.max 0, Math.floor(Math.log(Math.abs(y + 10)) / b10)
    lz = Math.max 0, Math.floor(Math.log(Math.abs(z + 10)) / b10)
    x = x.substring 0, 4 + lx
    y = y.substring 0, 4 + ly
    z = z.substring 0, 4 + lz
    a = a.substring 0, 3
    b = b.substring 0, 3
    c = c.substring 0, 3
    rotations = " | " + a + " pi, " + b + "pi ," + c + " pi"
    return "[" + x + ", " + y + ", " + z + "]"
