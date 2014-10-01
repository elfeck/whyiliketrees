class window.MyTree

  constructor: ->
    @_program = new ShaderProgram
    @_program.initGL()
    @_program.addUniformGL "mvp_matrix", Display.mvpMatrix
    @_program.addUniformGL "color", new Vec [0.4, 0.6, 0.2, 1.0]

    attribs =
      "vert_pos": 4
    @_geom = new Geom
    @_geom.initGL(@_program, attribs)
    @_geom.vData = [
      0, 0, 0, 1,
      40, 0, 0, 1,
      40, 40, 0, 1,
      0, 40, 0, 1
    ]
    @_geom.iData = [0, 1, 2, 2, 3, 0]
    @_geom.uploadGL()

  drawGL: ->
    @_program.bindGL()
    @_geom.bindGL()
    GL.drawElements(GL.TRIANGLES, 6, GL.UNSIGNED_SHORT, 0)
    @_geom.unbindGL()
    @_program.unbindGL()

  doLogic: (delta) ->
    @_geom.vData[0] += 1
    @_geom.vData[1] += 1
    @_geom.updateGL()
