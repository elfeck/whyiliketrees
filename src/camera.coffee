class window.Camera

  constructor: ->
    @_zNear = 0.5
    @_zFar = 3.0
    @_scale = 1.0

    @_cameraPosition = [0.0, 0.0, 0.0]

    n = @_zNear
    f = @_zFar
    @_pMatrix = [
      @_scale, 0.0, 0.0, 0.0,
      0.0, @_scale, 0.0, 0.0,
      0.0, 0.0, (f + n) / (n - f), 2 * n * f / (n - f),
      0.0, 0.0, -1.0, 0.0
    ]

    @_speed = 0.001

  addToProgram: (program) ->
    program.addUniformGL "p_matrix", new Mat(4, 4, @_pMatrix)
    program.addUniformGL "camera_pos", new Vec(@_cameraPosition)

  doLogic: (delta) ->
    if window.input.keyPressed 65
      @_cameraPosition[0] += @_speed * delta
    if window.input.keyPressed 68
      @_cameraPosition[0] -= @_speed * delta
    if window.input.keyPressed 83
      @_cameraPosition[2] -= @_speed * delta
    if window.input.keyPressed 87
      @_cameraPosition[2] += @_speed * delta
    if window.input.keyPressed 32
      @_cameraPosition[1] -= @_speed * delta
    if not window.input.keyPressed 32
      @_cameraPosition[1] = Math.min 0, (@_cameraPosition[1] + @_speed * delta)
