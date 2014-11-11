window.worldVert = "
#version 100\n
precision mediump float;

attribute vec4 vert_pos;
attribute vec3 vert_col;
attribute vec3 vert_norm;

uniform vec3 offs;
uniform mat4 vp_matrix;

varying vec3 frag_pos;
varying vec3 frag_col;
varying vec3 frag_norm;

void main() {
  gl_Position = vp_matrix * (vert_pos + vec4(offs.xyz, 0));

  frag_pos = vert_pos.xyz;
  frag_col = vert_col;
  frag_norm = vert_norm;
}
"

window.worldFrag = "
#version 100\n
precision mediump float;

const int max_lights = 8;

struct Light {
 float light_att;
 vec3 light_pos;
 vec3 light_int;
 vec3 light_amb;
};

uniform Light lights[max_lights];

varying vec3 frag_pos;
varying vec3 frag_col;
varying vec3 frag_norm;

vec3 compLight();

void main() {
  gl_FragColor = vec4(compLight(), 1.0);
}

vec3 compLight() {
  vec3 total_light = vec3(0.0);
  vec3 light_dir = vec3(0.0);
  float dist = 0.0;
  float att_factor = 0.0;
  float cos_ang = 0.0;

  for(int i = 0; i < max_lights; ++i) {
    if(lights[i].light_att == 0.0) break;
    light_dir = (lights[i].light_pos - frag_pos);
    dist = length(light_dir);
    att_factor = max(0.0, 1.0 - dist / lights[i].light_att);

    light_dir = normalize(light_dir);
    cos_ang = dot(normalize(frag_norm), light_dir);
    cos_ang = clamp(cos_ang, 0.0, 1.0);

    total_light += cos_ang * att_factor * lights[i].light_int *
      frag_col;
  }

  return total_light + frag_col * lights[0].light_amb;
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
