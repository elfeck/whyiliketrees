class window.Scene

  constructor: ->
    @_program = new ShaderProgram window.worldVert, window.worldFrag
    @_program.initGL()

    @_debugProgram = new ShaderProgram window.wireVert, window.wireFrag
    @_debugProgram.initGL()

    @_globalLights = []
    @initLights()

    window.camera.addToProgram @_program, 0
    window.camera.addToProgram @_debugProgram, 0
    gl.addToProgram @_program, 0 for gl in @_globalLights

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
    light_dist = -100
    light_height = 150
    light_int = 180
    @_globalLights = [
      new PointLight(
        new Vec(3, [0.0, 20.0, 0.0]),
        new Vec(1, [150]),
        0,
        new Vec(3, [0.85, 0.85, 0.85])),
      new PointLight(
        new Vec(3, [-light_dist, light_height, 0]),
        new Vec(1, [light_int]),
        1,
        new Vec(3, [0.65, 0.65, 0.65])),
      new PointLight(
        new Vec(3, [light_dist, light_height, 0]),
        new Vec(1, [light_int]),
        2,
        new Vec(3, [0.65, 0.65, 0.65])),
      new PointLight(
        new Vec(3, [0, light_height, -light_dist]),
        new Vec(1, [light_int]),
        3,
        new Vec(3, [0.65, 0.65, 0.65])),
      new PointLight(
        new Vec(3, [0.0, light_height, light_dist]),
        new Vec(1, [light_int]),
        4,
        new Vec(3, [0.65, 0.65, 0.65])),
      new PointLight(
        new Vec(3, [0.0, 250.0, 0.0]),
        new Vec(1, [300]),
        5,
        new Vec(3, [0.5, 0.5, 0.5]))
    ]
