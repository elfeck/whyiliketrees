class window.DirLight

  constructor: (@lightDir, @lightInt = new Vec(3, [0.7, 0.7, 0.7]),
    @lightAmb = new Vec(3, [0.3, 0.3, 0.3])) ->

  addToProgram: (program, id = 0) ->
    program.addUniformGL id, "light_dir", @lightDir
    program.addUniformGL id, "light_int", @lightInt
    program.addUniformGL id, "light_amb", @lightAmb
    return
