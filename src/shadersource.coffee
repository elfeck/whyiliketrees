window.worldVert = "
#version 100\n
precision mediump float;

attribute vec4 vert_pos;
attribute vec3 vert_col;
attribute vec3 vert_norm;

uniform mat4 vp_matrix;

varying vec3 frag_pos;
varying vec3 frag_col;
varying vec3 frag_norm;

void main() {
  gl_Position = vp_matrix * vert_pos;

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
};

uniform Light lights[max_lights];
uniform vec3 light_attenu;

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

  return total_light * frag_col + light_attenu * frag_col;
}
"

window.wireVert = "
#version 100\n
precision mediump float;

attribute vec4 vert_pos;
attribute vec3 vert_col;
attribute vec3 vert_norm;

uniform vec3 offs;
uniform mat4 vp_matrix;

varying vec3 frag_col;

void main() {
  frag_col = vert_col;
  gl_Position = vp_matrix * (vert_pos + vec4(offs.xyz, 0));
}
"

window.wireFrag = "
#version 100\n
precision mediump float;

varying vec3 frag_col;

void main() {
  gl_FragColor = vec4(frag_col, 1.0);
}
"
