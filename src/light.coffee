class window.DirLight

  constructor: (@lightDir, @lightInt = new Vec(3, [0.7, 0.7, 0.7])) ->

  addToProgram: (program, id = 0) ->
    program.addUniformGL id, "light_dir", @lightDir
    program.addUniformGL id, "light_int", @lightInt
    program.addUniformGL id, "light_amb", @lightAmb
    return


class window.PointLight

  constructor: (@lightPos, @lightAtt, @number = 0,
    @lightInt = new Vec(3, [0.7, 0.7, 0.7])) ->


  addToProgram: (program, id = 0) ->
    program.addUniformGL id, "lights[" + @number + "].light_att", @lightAtt
    program.addUniformGL id, "lights[" + @number + "].light_pos", @lightPos
    program.addUniformGL id, "lights[" + @number + "].light_int", @lightInt
    return

class window.AttenuationLight

  constructor: (@lightInt = new Vec(3, [0.3, 0.3, 0.3])) ->

  addToProgram: (program, id = 0) ->
    program.addUniformGL id, "light_attenu", @lightInt
    return
