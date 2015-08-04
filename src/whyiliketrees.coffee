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

    @last = new Date().getTime()
    @delta = 0
    @deltaItv = 200
    @deltaAcm = 200
    @cameraItv = 200
    @cameraAcm = 200
    @dprintItv = 1000
    @dprintAcm = 1000

    @deltaAvgItv = 5000
    @deltaAvgAcm = 5000

    @ticks = 0
    @deltaSum = 0
    @deltaAvg = 0

    @scenes = []
    @currentScene = 1

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
    window.initShadersGL()
    @scenes.push new TestScene
    @scenes.push new SpikyScene
    window.dbgSetInfo 1, "Current Scene: [" + @currentScene + ", " +
      @scenes[@currentScene].debugName + "]"
    return

  compTime: ->
    date = new Date()
    @delta = date.getTime() - @last
    @last = date.getTime()
    @deltaAcm += @delta
    @cameraAcm += @delta
    @deltaAvgAcm += @delta
    @ticks++
    @deltaSum += @delta

    if @deltaAcm >= @deltaItv
      window.dbgSetInfo 3, @delta + "ms delta  [" +
        (@deltaAvg + "").substring(0, 4) + "ms]"
      @deltaAcm = 0
      @setGeomDebugInfo() # should not be here but lazy

    if @deltaAvgAcm >= @deltaAvgItv
      @deltaAvg = @deltaSum / @ticks
      window.dbgSetInfo 3, @delta + "ms delta  [" +
        (@deltaAvg + "").substring(0, 4) + "ms]"
      @deltaAvgAcm = 0
      @ticks = 0
      @deltaSum = 0

    if @cameraAcm >= @cameraItv
      window.dbgSetInfo 5, "Camera " + window.camera.posToString()
      @cameraAcm = 0
    return

  checkScene: ->
    for i in [49..57]
      if input.keyPressed i
        ind = i - 49
        if ind < @scenes.length
          @currentScene = ind
          window.dbgSetInfo 1, "Current Scene: [" + ind + ", " +
            @scenes[@currentScene].debugName + "]"
        else
          dprint "No Scene available for [" + ind + "]   :("
    return

  dbgResetConsole: ->
    if @dprintAcm >= @dprintItv
      window._knownLines = []
      @dprintAcm = 0
    @dprintAcm += @delta
    return

  setGeomDebugInfo: ->
    geomInfo = @scenes[@currentScene].dbgGeomInfo()
    window.dbgSetInfo 2, "Primitive count: " + geomInfo[0]
    window.dbgSetInfo 4, "Draw calls: " + geomInfo[1]
    window.dbgSetInfo 6, "Subbuffer updates: " + (geomInfo[2] + geomInfo[3])
    return

  executeDrawGL: ->
    GL.clear (GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT)
    Geom.debugTotalDrawCalls = 0 # debug
    Geom.debugTotalUpdates = 0 #debug
    @scenes[@currentScene].delegateDrawGL()
    return

  executeDoLogic: ->
    @checkScene()
    @compTime()
    @dbgResetConsole()
    window.camera.doLogic @delta
    @scenes[@currentScene].delegateDoLogic @delta
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
