window.GL = undefined
window.camera = undefined
window.input = undefined
window.display = undefined

window.debug = true
window.consoleLog = true
window.mouseActive = false

class window.Display

  constructor: ->

    @width = 600
    @height = 400

    @_last = new Date().getTime()
    @_delta = 0
    @_deltaItv = 100
    @_deltaAcm = 100
    @_cameraItv = 200
    @_cameraAcm = 200
    @_dprintItv = 1000
    @_dprintAcm = 1000

    @_deltaAvgItv = 5000
    @_deltaAvgAcm = 5000

    @_ticks = 0
    @_deltaSum = 0
    @_deltaAvg = 0

    @_scene = undefined

  initGL: (canvas) ->
    canvas.setAttribute("width", @width)
    canvas.setAttribute("height", @height)
    window.GL = canvas.getContext "experimental-webgl", {
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
    @_deltaAvgAcm += @_delta
    @_ticks++
    @_deltaSum += @_delta

    if @_deltaAcm >= @_deltaItv
      window.setInfo 2, @_delta + "ms delta  [" +
        (@_deltaAvg + "").substring(0, 4) + "ms]"
      @_deltaAcm = 0

    if @_deltaAvgAcm >= @_deltaAvgItv
      @_deltaAvg = @_deltaSum / @_ticks
      window.setInfo 2, @_delta + "ms delta  [" +
        (@_deltaAvg + "").substring(0, 4) + "ms]"
      @_deltaAvgAcm = 0
      @_ticks = 0
      @_deltaSum = 0

    if @_cameraAcm >= @_cameraItv
      window.setInfo 1, "camera " + window.camera.posToString()
      @_cameraAcm = 0
    return

  resetDprint: ->
    if @_dprintAcm >= @_dprintItv
      window._knownLines = []
      @_dprintAcm = 0
    @_dprintAcm += @_delta

  executeDrawGL: ->
    GL.clear (GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT)
    @_scene.delegateDrawGL()
    return

  executeDoLogic: ->
    @compTime()
    @resetDprint()
    window.camera.doLogic @_delta
    @_scene.delegateDoLogic @_delta
    window.input.reset()
    return

  # maybe more scenes later
  currentScene: ->
    return @_scene

updateGL = ->
  window.display.executeDoLogic()
  window.display.executeDrawGL()
  window.requestAnimationFrame updateGL
  return

document.addEventListener('DOMContentLoaded', () ->
  window.display = new Display
  window.display.initGL document.getElementById("canvas")
  window.display.initGame()
  updateGL()
  return
)
