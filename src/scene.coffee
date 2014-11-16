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
      new MyTree @_program, @_debugProgram, @_geom
    ]

  delegateDrawGL: ->
    e.drawGL() for e in @_entities
    return

  delegateDoLogic: (delta) ->
    e.doLogic delta for e in @_entities
    return

  initLights: ->
    @_gloLights = []
    att = new Vec 1, [180]
    int = new Vec 3, [0.85, 0.85, 0.85]
    @_gloLights.push new PointLight( new Vec(3, [0, 100, 100.0]), att, 0, int)
    @_gloLights.push new PointLight( new Vec(3, [0, 100, -100.0]), att, 1, int)
    @_gloLights.push new PointLight( new Vec(3, [100, 100, 0]), att, 2, int)
    @_gloLights.push new PointLight( new Vec(3, [-100, 100, 0]), att, 3, int)
