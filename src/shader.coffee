simpleVert = "
#version 100\n
precision mediump float;

attribute vec4 vert_pos;

void main() {
  gl_Position = vert_pos;
}
"

simpleFrag = "
#version 100\n
precision mediump float;

void main() {
  gl_FragColor = vec4(0.8, 0.0, 0.0, 1.0);
}
"

class window.Shader

  constructor: (@_vertSrc = simpleVert, @_fragSrc = simpleFrag) ->
    @_vertSrc = simpleVert
    @_vert = undefined
    @_fragSrc = simpleFrag
    @_frag = undefined
    @_program = undefined

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

  bindGL: ->
    GL.useProgram @_program

  unbindGL: ->
    GL.useProgram null

  getAttribLocGL: (name) ->
    return GL.getAttribLocation @_program, name
