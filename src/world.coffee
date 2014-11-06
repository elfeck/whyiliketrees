class window.World

  constructor: ->
    @_quadProgram = new ShaderProgram
    @_quadProgram.initGL()
    @_quadProgram.addUniformGL 0, "vp_matrix", window.camera.getVPMat()

    @_quadGeom = new Geom
    attribs =
      "vert_pos": 4
      "vert_col": 4
    @_quadGeom.initGL(@_quadProgram, attribs)

    @_quads = []
    for i in [0..10]
      for j in [0..10]
        @_quads.push new Quad(
          [i * 2.0, 0.0, j * 2.0],
          [i * 0.1, j * 0.1, 0.0, 1.0],
          2.0,
          @_quadProgram,
          @_quadGeom)

  drawGL: ->
    @_quadGeom.drawGL()
    return

  doLogic: (delta) ->
    q.doLogic delta for q in @_quads
    return
