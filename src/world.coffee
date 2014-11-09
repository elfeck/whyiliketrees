class window.World

  constructor: ->
    @_uid = window.get_uid()
    @_program = new ShaderProgram window.quadVert, window.quadFrag
    @_program.initGL()
    @_program.addUniformGL 0, "vp_matrix", window.camera.getVPMat()

    attribs =
      "vert_pos": 4
      "vert_col": 4
    @_geom = new Geom
    @_geom.initGL(@_program, attribs)

    @vecNet = []
    @generateWorld()


  drawGL: ->
    @_geom.drawGL(@_uid)
    return

  doLogic: (delta) ->
    return

  generateWorld: ->
    size = 8
    total = 20
    for z in [0..total-1] by 1
      for x in [0..total-1] by 1
        @vecNet.push new Vec 4,
          [x * size, Math.random() * size, z * size, 1.0]

    prims = []
    vRaw = []
    iRaw = []
    offs = 0
    for z in [0..total-2] by 1
      for x in [0..total-2] by 1
        prim1 = new Primitive 3
        prim2 = new Primitive 3
        col = new Vec 4, [z / total, x / total, 0.2, 1.0]

        v1 = [new Vertex, new Vertex, new Vertex]
        v1[0].data.push @vecNet[z * total + x]
        v1[1].data.push @vecNet[z * total + x + 1]
        v1[2].data.push @vecNet[(z + 1) * total + x + 1]

        v2 = [new Vertex, new Vertex, new Vertex]
        v2[0].data.push @vecNet[z * total + x]
        v2[1].data.push @vecNet[(z + 1) * total + x + 1]
        v2[2].data.push @vecNet[(z + 1) * total + x]

        for i in [0..2] by 1
          v1[i].data.push col
          v2[i].data.push col

        prim1.vertices = v1
        prim2.vertices = v2
        prims.push prim1
        prims.push prim2
        prim1.fetchVertexData vRaw
        prim2.fetchVertexData vRaw
        offs = prim1.fetchIndexData iRaw, offs
        offs = prim2.fetchIndexData iRaw, offs

    @_geom.addDataSet @_uid, vRaw, iRaw

###y
size = 20
total = 10
vertexNet = []
for z in [0..total-1] by 1
  for x in [0..total-1] by 1
    vert = new Vertex z * total + x
    vert.data.push new Vec(4, [x * size, 0.0, z * size, 1.0])
    vert.data.push new Vec(4, [x / total, z / total, 0.5, 1.0])
    vertexNet.push vert

prims = []
for z in [0..total-2]
  for x in [0..total-2]
    p1 = new Primitive 3
    p1.vertices.push vertexNet[z * total + x]
    p1.vertices.push vertexNet[z * total + x + 1]
    p1.vertices.push vertexNet[(z + 1) * total + x + 1]

    p2 = new Primitive 3
    p2.vertices.push vertexNet[z * total + x]
    p2.vertices.push vertexNet[(z + 1) * total + x + 1]
    p2.vertices.push vertexNet[(z + 1) * total + x]

    prims.push p1
    prims.push p2
vRaw = []
iRaw = []
v.fetchVertexData vRaw for v in vertexNet
p.fetchIndexData iRaw, 0 for p in prims

@_geom.addDataSet @_uid, vRaw, iRaw
###
