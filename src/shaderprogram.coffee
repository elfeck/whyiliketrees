class window.ShaderProgram

  constructor: (@vertSrc, @fragSrc) ->
    @vert = undefined
    @frag = undefined
    @program = undefined
    @uniforms = []

  initGL: ->
    @vert = GL.createShader GL.VERTEX_SHADER
    GL.shaderSource @vert, @vertSrc
    GL.compileShader @vert
    if not GL.getShaderParameter @vert, GL.COMPILE_STATUS
      console.log "Error in compile shader :vert: \n" +
        GL.getShaderInfoLog @vert

    @frag = GL.createShader GL.FRAGMENT_SHADER
    GL.shaderSource @frag, @fragSrc
    GL.compileShader @frag
    if not GL.getShaderParameter @frag, GL.COMPILE_STATUS
      console.log "Error in compile shader :frag: \n" +
        GL.getShaderInfoLog @frag

    @program = GL.createProgram()

    attribNames = window.getShaderAttributes @vertSrc
    for i in [0..attribNames-1]
      GL.bindAttribLocation @program, i, attribNames[i]

    GL.attachShader @program, @vert
    GL.attachShader @program, @frag
    GL.linkProgram @program
    if not GL.getProgramParameter @program, GL.LINK_STATUS
      console.log "Error in link program \n" + GL.getProgramInfoLog @program
    return

  bindGL: ->
    GL.useProgram @program
    return

  unbindGL: ->
    GL.useProgram null
    return

  uploadUniformsGL: (id) ->
    for uni in @uniforms
      uni.uniform.asUniformGL uni.location if id == uni.id

  addUniformGL: (id, name, uniform) ->
    uni =
      id: id
      name: name #debug
      uniform: uniform
      location: GL.getUniformLocation @program, name
    @uniforms.push uni
    return
