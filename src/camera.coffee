class window.Camera

  constructor: ->
    @_zNear = 0.1
    @_zFar = 10.1
    @_scale = 1

    n = @_zNear
    f = @_zFar

    @_pMatrix = [
      1, 0.0, 0.0, 0.0,
      0.0, 1, 0.0, 0.0,
      0.0, 0.0, -(f + n) / (f - n), -1,
      0.0, 0.0, -2.0 * n * f / (f - n), 0.0
    ]
    @_vMatrix = [
      1.0, 0.0, 0.0, 0.0,
      0.0, 1.0, 0.0, 0.0,
      0.0, 0.0, 1.0, 0.0,
      0.0, 0.0, 0.0, 1.0
    ]

    @_speed = 0.001

  addPToProgram: (program) ->
    program.addUniformGL "v_matrix", new Mat(4, 4, @_vMatrix)
    program.addUniformGL "p_matrix", new Mat(4, 4, @_pMatrix)

  timepassed = 0
  doLogic: (delta) ->
    if window.input.keyPressed 65
      @_vMatrix[12] += @_speed * delta
    if window.input.keyPressed 68
      @_vMatrix[12] -= @_speed * delta
    if window.input.keyPressed 83
      @_vMatrix[14] -= @_speed * delta
    if window.input.keyPressed 87
      @_vMatrix[14] += @_speed * delta
    if window.input.keyPressed 78
      @_vMatrix[13] -= @_speed * delta
    if window.input.keyPressed 77
      @_vMatrix[13] += @_speed * delta

    if timepassed > 1000
      #console.log @_cameraPosition
      timepassed = 0
    else
      timepassed += delta
