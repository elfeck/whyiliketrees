class window.MyTree

  constructor: (s, offs) ->
    @_program = new ShaderProgram
    @_program.initGL()
    @_program.addUniformGL "offset", new Vec(offs)

    window.camera.addPToProgram @_program

    attribs =
      "vert_pos": 4
      "vert_col": 4

    @_geom = new Geom
    @_geom.initGL(@_program, attribs)

    @_geom.vData = [
      #green
      0, 0, 0.0, 1.0,
      0.0, 1.0, 0.0, 1.0,

      s, 0, 0.0, 1.0,
      0.0, 1.0, 0.0, 1.0,

      s, s, 0.0, 1.0,
      0.0, 1.0, 0.0, 1.0,

      0, s, 0.0, 1.0,
      0.0, 1.0, 0.0, 1.0,

      #red
      0, 0, -s, 1.0,
      1.0, 0.0, 0.0, 1.0,

      s, 0, -s, 1.0,
      1.0, 0.0, 0.0, 1.0,

      s, s, -s, 1.0,
      1.0, 0.0, 0.0, 1.0,

      0, s, -s, 1.0,
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
