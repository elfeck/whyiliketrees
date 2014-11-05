(($) -> ) jQuery

_id = 1
window.get_uid = ->
  _id++
  return _id - 1

window.GL = undefined
window.display = undefined
window.camera = undefined
window.input = undefined

class window.Display

  constructor: ->

    @width = 600
    @height = 400

    @_last = new Date().getTime()
    @_delta = 0
    @_printInterval = 2000
    @_printAccum = 2000

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
    @_printAccum += @_delta
    if @_printAccum >= @_printInterval
      console.log @_delta + "ms delta"
      @_printAccum = 0
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
