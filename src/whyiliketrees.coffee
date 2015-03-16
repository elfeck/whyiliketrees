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
    @_deltaItv = 200
    @_deltaAcm = 200
    @_cameraItv = 200
    @_cameraAcm = 200
    @_dprintItv = 1000
    @_dprintAcm = 1000

    @_deltaAvgItv = 5000
    @_deltaAvgAcm = 5000

    @_ticks = 0
    @_deltaSum = 0
    @_deltaAvg = 0

    @_scenes = []
    @_currentScene = 0

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
    @_scenes.push new TestScene
    window.setInfo 1, "Current Scene: [" + @_currentScene + ", " +
      @_scenes[@_currentScene].debugName + "]"
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
      window.setInfo 3, @_delta + "ms delta  [" +
        (@_deltaAvg + "").substring(0, 4) + "ms]"
      @_deltaAcm = 0
      @setGeomDebugInfo() # should not be here but lazy

    if @_deltaAvgAcm >= @_deltaAvgItv
      @_deltaAvg = @_deltaSum / @_ticks
      window.setInfo 3, @_delta + "ms delta  [" +
        (@_deltaAvg + "").substring(0, 4) + "ms]"
      @_deltaAvgAcm = 0
      @_ticks = 0
      @_deltaSum = 0

    if @_cameraAcm >= @_cameraItv
      window.setInfo 5, "Camera " + window.camera.posToString()
      @_cameraAcm = 0
    return

  checkScene: ->
    for i in [49..57]
      if input.keyPressed i
        ind = i - 49
        if ind < @_scenes.length
          @_currentScene = ind
          window.setInfo 1, "Current Scene: [" + ind + ", " +
            @_scenes[@_currentScene].debugName + "]"
        else
          dprint "No Scene available for [" + ind + "]   :("
    return

  resetDprint: ->
    if @_dprintAcm >= @_dprintItv
      window._knownLines = []
      @_dprintAcm = 0
    @_dprintAcm += @_delta
    return

  setGeomDebugInfo: ->
    window.setInfo 2, "Primitive count: " + Geom.debugTotalPrimCount
    window.setInfo 4, "Draw calls: " + Geom.debugTotalDrawCalls
    window.setInfo 6, "Subbuffer updates: " + Geom.debugTotalUpdates
    return

  executeDrawGL: ->
    GL.clear (GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT)
    Geom.debugTotalDrawCalls = 0 # debug
    @_scenes[@_currentScene].delegateDrawGL()
    return

  executeDoLogic: ->
    @checkScene()
    @compTime()
    @resetDprint()
    window.camera.doLogic @_delta
    Geom.debugTotalUpdates = 0 # debug
    @_scenes[@_currentScene].delegateDoLogic @_delta
    window.input.reset()
    return

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
