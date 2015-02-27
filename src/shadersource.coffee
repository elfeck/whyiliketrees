window.colLineVert = "
#version 100\n
precision mediump float;

attribute vec4 vert_pos;
attribute vec3 vert_col;

uniform mat4 vp_matrix;
uniform vec3 offs;

varying vec3 frag_col;

void main() {
  gl_Position = vp_matrix * vec4(vert_pos.xyz + offs, 1.0);
  frag_col = vert_col;
}
"

window.colLineFrag = "
#version 100\n
precision mediump float;

varying vec3 frag_col;

void main() {
  gl_FragColor = vec4(frag_col, 1.0);
}
"
