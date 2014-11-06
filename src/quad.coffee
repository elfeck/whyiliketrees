class window.Quad

  constructor: (pos, col, s, @_program, @_geom) ->
    @_uid = window.get_uid()

    @_program.addUniformGL @_uid, "offs", new Vec(3, pos)

    s /= 2.0
    vData = [
      #green
      -s, 0.0, -s, 1.0,
      col[0], col[1], col[2], col[3],

      s, 0.0, -s, 1.0,
      col[0], col[1], col[2], col[3],

      s, 0.0, s, 1.0,
      col[0], col[1], col[2], col[3],

      -s, 0.0, s, 1.0,
      col[0], col[1], col[2], col[3]
    ]
    iData = [
      0, 1, 2, 2, 3, 0
    ]
    @_geom.addDataSet @_uid, vData, iData

  doLogic: (delta) ->
    return
