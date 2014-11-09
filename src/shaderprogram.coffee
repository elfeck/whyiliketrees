window.worldVert = "
#version 100\n
precision mediump float;

attribute vec4 vert_pos;
attribute vec3 vert_col;
attribute vec3 vert_norm;

uniform vec3 offs;
uniform mat4 vp_matrix;

uniform vec3 light_dir;
uniform vec3 light_int;
uniform vec3 light_amb;

varying vec3 frag_col;

void main() {
  gl_Position = vp_matrix * (vert_pos + vec4(offs.xyz, 0));
  float cAng = dot(vert_norm, normalize(light_dir));
  cAng = clamp(cAng, 0.0, 1.0);
  frag_col = light_int * vert_col * cAng + light_amb * vert_col;
}
"

window.worldFrag = "
#version 100\n
precision mediump float;

varying vec3 frag_col;

void main() {
  gl_FragColor = vec4(frag_col.xyz, 1.0);
}
"

class window.ShaderProgram

  constructor: (@_vertSrc, @_fragSrc) ->
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

    attribNames = window.getShaderAttributes @_vertSrc
    for i in [0..attribNames-1]
      GL.bindAttribLocation @_program, i, attribNames[i]

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

  addUniformGL: (id, name, uniform) ->
    uni =
      id: id
      uniform: uniform
      location: GL.getUniformLocation @_program, name
    @_uniforms.push uni
    return
