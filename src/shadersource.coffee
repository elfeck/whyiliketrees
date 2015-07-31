window.shaders = []
window.initShadersGL = ->
  window.shaders["lineShader"] = new ShaderProgram lineVert, lineFrag
  window.shaders["lineShader"].initGL()

  window.shaders["fillShader"] = new ShaderProgram fillVert, fillFrag
  window.shaders["fillShader"].initGL()
  return


# ###########
# Line Shader
# ###########

lineVert = "
#version 100\n
precision mediump float;\n

attribute vec4 vert_pos;\n
attribute vec3 vert_col;\n

uniform mat4 vp_matrix;\n
uniform vec3 offs;\n

varying vec3 frag_col;\n

void main() {\n
  gl_Position = vp_matrix * vec4(vert_pos.xyz + offs, 1.0);\n
  frag_col = vert_col;\n
}\n
"

lineFrag = "
#version 100\n
precision mediump float;\n

varying vec3 frag_col;\n

void main() {\n
  gl_FragColor = vec4(frag_col, 1.0);\n
}\n
"


# ###########
# Area Shader
# ###########

fillVert = "
#version 100\n
precision mediump float;\n

attribute vec4 vert_pos;\n
attribute vec3 vert_col;\n
attribute vec3 vert_norm;\n

uniform mat4 vp_matrix;\n
uniform vec3 offs;\n

varying vec3 frag_pos;\n
varying vec3 frag_col;\n
varying vec3 frag_norm;\n

void main() {\n
  gl_Position = vp_matrix * vec4(vert_pos.xyz + offs, 1.0);\n

  frag_pos = vert_pos.xyz + offs;\n
  frag_col = vert_col;\n
  frag_norm = vert_norm;\n
}\n
"

fillFrag = "
#version 100\n
precision mediump float;\n

const int max_lights = 8;\n

struct Light {\n
 float light_att;\n
 vec3 light_pos;\n
 vec3 light_int;\n
};\n

uniform Light lights[max_lights];\n
uniform vec3 light_attenu;\n
uniform float num_lights;\n

varying vec3 frag_pos;\n
varying vec3 frag_col;\n
varying vec3 frag_norm;\n

vec3 compLight();\n

void main() {\n
  gl_FragColor = vec4(compLight(), 1.0);\n
}\n

vec3 compLight() {\n
  vec3 total_light = vec3(0.0);\n
  vec3 light_dir = vec3(0.0);\n
  float dist = 0.0;\n
  float att_factor = 0.0;\n
  float cos_ang = 0.0;\n
  int num_l = int(num_lights);\n

  for(int i = 0; i < max_lights; ++i) {\n
    if(i >= int(num_lights)) break;\n
    light_dir = (lights[i].light_pos - frag_pos);\n
    dist = length(light_dir);\n
    att_factor = max(0.0, 1.0 - dist / lights[i].light_att);\n

    cos_ang = dot(normalize(frag_norm), normalize(light_dir));\n
    cos_ang = clamp(cos_ang, 0.0, 1.0);\n

    total_light += cos_ang * att_factor * lights[i].light_int * frag_col;\n
  }
  return total_light * frag_col + light_attenu * frag_col;\n
}\n
"
