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
    @debugCube = undefined

  addToProgram: (program, id = 0) ->
    program.addUniformGL id, "lights[" + @number + "].light_att", @lightAtt
    program.addUniformGL id, "lights[" + @number + "].light_pos", @lightPos
    program.addUniformGL id, "lights[" + @number + "].light_int", @lightInt
    return

  dbgAddCube: (size = 2, color = @lightInt) ->
    @debugCube = new Cube(@lightPos.copy(), size)
    return @debugCube.gfxAddFill color

  dbgUpdate: ->
    @debugCube.setCenter @lightPos.copy() if @debugCube?
    return

  linesFromPosition: (color = new Vec(3, [0.0, 1.0, 0.0]), num = 3) ->
    dirs = [
      new Vec(3, [1.0, 0.0, 0.0]), new Vec(3, [0.0, 1.0, 0.0]),
      new Vec(3, [0.0, 0.0, 1.0]), new Vec(3, [1.0, 1.0, 0.0]),
      new Vec(3, [1.0, 0.0, 1.0]), new Vec(3, [0.0, 1.0, 0.0]),
      new Vec(3, [-1.0, 1.0, 0.0]), new Vec(3, [-1.0, 0.0, 1.0]),
      new Vec(3, [0.0, -1.0, 1.0])
    ]
    num = Math.min(dirs.length, num)
    l = @lightAtt.data[0]
    prims = []
    for i in [1..num]
      line = new Line @lightPos, dirs[i - 1].normalize()
      prims = prims.concat line.getLineSegC(-l, l * 2.0, color)
    return prims

class window.AttenuationLight

  constructor: (@lightInt = new Vec(3, [0.3, 0.3, 0.3])) ->

  addToProgram: (program, id = 0) ->
    program.addUniformGL id, "light_attenu", @lightInt
    return
