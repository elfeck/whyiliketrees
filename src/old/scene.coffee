class window.Scene

  constructor: ->
    @_program = new ShaderProgram window.worldVert, window.worldFrag
    @_program.initGL()

    @_debugProgram = new ShaderProgram window.wireVert, window.wireFrag
    @_debugProgram.initGL()

    @_gloLights = []
    @initLights()

    window.camera.addToProgram @_program, 0
    window.camera.addToProgram @_debugProgram, 0
    gl.addToProgram @_program, 0 for gl in @_gloLights

    @_geom = new Geom [4, 3, 3]
    @_geom.initGL()

    @_entities = [
      new World @_program, @_debugProgram, @_geom
      new TheTree @_program, @_debugProgram, @_geom
    ]

  delegateDrawGL: ->
    @_geom.drawGL()
    e.drawGL() for e in @_entities
    return

  delegateDoLogic: (delta) ->
    e.doLogic delta for e in @_entities
    return

  initLights: ->
    @_gloLights = []
    att = new Vec 1, [150]
    int = new Vec 3, [0.85, 0.85, 0.85]
    @_gloLights.push new PointLight(new Vec(3, [0, 50, 0]), att, 0, int)
