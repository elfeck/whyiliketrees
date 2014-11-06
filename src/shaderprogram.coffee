simpleVert = "
#version 100\n
precision mediump float;

attribute vec4 vert_pos;
attribute vec4 vert_col;

uniform vec3 offs;
uniform mat4 vp_matrix;

varying vec4 frag_col;

void main() {
  gl_Position = vp_matrix * (vert_pos + vec4(offs.xyz, 0));
  frag_col = vec4(vert_col);
}
"

simpleFrag = "
#version 100\n
precision mediump float;

varying vec4 frag_col;

void main() {
  gl_FragColor = frag_col;
}
"

class window.ShaderProgram

  constructor: (@_vertSrc = simpleVert, @_fragSrc = simpleFrag) ->
    @_vertSrc = simpleVert
    @_fragSrc = simpleFrag
    @_vert = undefined
    @_frag = undefined
    @_program = undefined

    @_uniforms = []

  initGL: ->
    @_vert = GL.createShader GL.VERTEX_SHADER
    GL.shaderSource @_vert, @_vertSrc
    GL.compileShader @_vert
    if not GL.getShaderParameter @_vert, GL.COMPILE_STATUS
      console.log "Error in compile shader :vert: \n" +
        GL.getShaderInfoLog @_vert

    @_frag = GL.createShader GL.FRAGMENT_SHADER
    GL.shaderSource @_frag, @_fragSrc
    GL.compileShader @_frag
    if not GL.getShaderParameter @_frag, GL.COMPILE_STATUS
      console.log "Error in compile shader :frag: \n" +
        GL.getShaderInfoLog @_frag

    @_program = GL.createProgram()
    GL.attachShader @_program, @_vert
    GL.attachShader @_program, @_frag
    GL.linkProgram @_program
    if not GL.getProgramParameter @_program, GL.LINK_STATUS
      console.log "Error in link program \n" + GL.getProgramInfoLog @_program
    return

  bindGL: ->
    GL.useProgram @_program

  unbindGL: ->
    GL.useProgram null
    return

  uploadUniformsGL: (id) ->
    for uni in @_uniforms
      if id == uni.id
        uni.uniform.asUniformGL uni.location

  getAttribLocGL: (name) ->
    return GL.getAttribLocation @_program, name

  addUniformGL: (id, name, uniform) ->
    uni =
      id: id
      uniform: uniform
      location: GL.getUniformLocation @_program, name
    @_uniforms.push uni
    return
