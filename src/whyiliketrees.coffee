(($) -> ) jQuery

window.GL = undefined
window.camera = undefined
window.input = undefined
window.display = undefined
window.debug = true

class window.Display

  constructor: ->

    @width = 600
    @height = 400

    @_last = new Date().getTime()
    @_delta = 0
    @_deltaItv = 2000
    @_deltaAcm = 2000
    @_cameraItv = 200
    @_cameraAcm = 200

    @_scene = undefined

  initGL: (canvas) ->
    canvas.attr("width", @width)
    canvas.attr("height", @height)
    window.GL = canvas[0].getContext "experimental-webgl", {
      antialias: true
    }
    #console.log GL.getContextAttributes().antialias
    GL.clearColor 0.0, 0.0, 0.0, 1.0
    GL.clearDepth 1.0

    #GL.enable GL.CULL_FACE
    #GL.cullFace GL.BACK
    #GL.frontFace GL.CCW

    GL.enable GL.DEPTH_TEST
    #GL.depthMask GL.TRUE
    GL.depthFunc GL.LEQUAL
    GL.depthRange 0.0, 1.0
    return

  initGame: ->
    window.input = new Input canvas
    window.camera = new Camera
    @_scene = new Scene
    return

  compTime: ->
    date = new Date()
    @_delta = date.getTime() - @_last
    @_last = date.getTime()
    @_deltaAcm += @_delta
    @_cameraAcm += @_delta
    if @_deltaAcm >= @_deltaItv
      window.setInfo 2, @_delta + "ms delta"
      @_deltaAcm = 0
    if @_cameraAcm >= @_cameraItv
      window.setInfo 1, "camera " + window.camera.posToString()
      @_cameraAcm = 0
    return

  executeDrawGL: ->
    GL.clear (GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT)
    @_scene.delegateDrawGL()
    return

  executeDoLogic: ->
    @compTime()
    window.camera.doLogic @_delta
    @_scene.delegateDoLogic @_delta
    return

  # maybe more scenes later
  currentScene: ->
    return @_scene

updateGL = ->
  window.display.executeDoLogic()
  window.display.executeDrawGL()
  window.requestAnimationFrame updateGL
  return

$ ->
  window.display = new Display
  window.display.initGL $("#canvas")
  window.display.initGame()
  updateGL()
  return
