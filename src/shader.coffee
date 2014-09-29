simpleVert = "
#version 100
precision mediump float;

attribute vec4 vert_position;

void main() {
  gl_Position = vert_position;
}
"

simpleFrag = "
#version 100
precision mediump float;

void main() {
  gl_FragColor = vec4(0.8, 0.0, 0.0, 1.0);
}
"

class window.Shader
  constructor: ->
    @vertSrc = simpleVert
    @fragSrc = simpleFrag
