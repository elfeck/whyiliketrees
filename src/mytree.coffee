class window.MyTree

  constructor: ->
    @_program = new ShaderProgram
    @_program.initGL()

    attribs =
      "vert_pos": 4
      "vert_col": 4
    @_geom = new Geom
    @_geom.initGL(@_program, attribs)
    @_geom.vData = [
      #front green
      0.2, 0.2, 0.0, 1.0,
      0.0, 1.0, 0.0, 1.0,

      0.5, 0.2, 0.0, 1.0,
      0.0, 1.0, 0.0, 1.0,

      0.5, 0.5, 0.0, 1.0,
      0.0, 1.0, 0.0, 1.0,

      0.2, 0.5, 0.0, 1.0,
      0.0, 1.0, 0.0, 1.0,

      #back red
      0.2, 0.2, 0.5, 1.0,
      1.0, 0.0, 0.0, 1.0,

      0.5, 0.2, 0.5, 1.0,
      1.0, 0.0, 0.0, 1.0,

      0.5, 0.5, 0.5, 1.0,
      1.0, 0.0, 0.0, 1.0,

      0.2, 0.5, 0.5, 1.0,
      1.0, 0.0, 0.0, 1.0
    ]
    @_geom.iData = [
      0, 1, 2, 2, 3, 0, #front
      4, 5, 6, 6, 7, 4, #back

      0, 1, 5, 5, 4, 0, #bottom
      2, 6, 7, 7, 3, 2, #top

      1, 5, 6, 6, 2, 1, #left
      0, 4, 7, 7, 3, 0  #right
    ]
    @_geom.uploadGL()

  drawGL: ->
    @_program.bindGL()
    @_geom.bindGL()
    GL.drawElements(GL.TRIANGLES, 6 * 6, GL.UNSIGNED_SHORT, 0)
    @_geom.unbindGL()
    @_program.unbindGL()

  doLogic: (delta) ->
