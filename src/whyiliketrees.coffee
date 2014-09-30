# Apparently needed
(($) -> ) jQuery

window.GL = undefined
window.display = undefined

class window.Display

  constructor: ->
    @width = 600
    @height = 400

    @_last = new Date().getTime()
    @_delta = 0
    @_printInterval = 2000
    @_printAccum = 2000

  initGL: (canvas) ->
    canvas.attr("width", @width)
    canvas.attr("height", @height)
    window.GL = canvas[0].getContext "experimental-webgl"
    GL.clearColor 0.8, 1.0, 1.0, 1.0

  compTime: ->
    date = new Date()
    @_delta = date.getTime() - @_last
    @_last = date.getTime()
    @_printAccum += @_delta
    if @_printAccum >= @_printInterval
      console.log @_delta + "ms delta"
      @_printAccum = 0

  drawGL: ->
    GL.clear GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT
    @compTime()

updateGL = ->
  window.display.drawGL()
  window.requestAnimationFrame updateGL

$ ->
  window.display = new Display
  window.display.initGL $("#canvas")
  updateGL()
