class window.Quad

  constructor: (pos, s, @_program) ->
    @_uid = window.get_uid()

    @_program.addUniformGL @_uid, "offs", new Vec(3, pos)

    attribs =
      "vert_pos": 4
      "vert_col": 4

    @_geom = new Geom
    @_geom.initGL(@_program, attribs)

    s /= 2.0
    @_geom.vData = [
      #green
      -s, 0.0, -s, 1.0,
      0.0, 1.0, 0.0, 1.0,

      s, 0.0, -s, 1.0,
      0.0, 1.0, 0.0, 1.0,

      s, 0.0, s, 1.0,
      0.0, 1.0, 0.0, 1.0,

      -s, 0.0, s, 1.0,
      0.0, 1.0, 0.0, 1.0,
    ]

    @_geom.iData = [
      0, 1, 2, 2, 3, 0
    ]
    @_geom.uploadGL()

  drawGL: ->
    @_program.bindGL(@_uid)
    @_geom.bindGL()
    GL.drawElements(GL.TRIANGLES, 6 * 1, GL.UNSIGNED_SHORT, 0)
    @_geom.unbindGL()
    @_program.unbindGL(@_uid)
    return

  doLogic: (delta) ->
    return
