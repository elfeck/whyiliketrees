class window.Scene

  constructor: ->
    @_program = new ShaderProgram()
    @_program.initGL()
    @_program.addUniformGL 0, "vp_matrix", window.camera.getVPMat()

    @_entities = [
      new Quad([0.0, 0.0, 0.0], 10, @_program),
      new Quad([-11.0, 0.0, 0.0], 10, @_program)
    ]

  delegateDrawGL: ->
    e.drawGL() for e in @_entities
    return

  delegateDoLogic: (delta) ->
    e.doLogic(delta) for e in @_entities
    return
