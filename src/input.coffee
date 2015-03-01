class window.Input

  constructor: () ->
    @_keys = (false for [1..255])
    @_canvas = document.getElementById "canvas"

    @mouseX = undefined
    @mouseY = undefined
    @mouseDown = false

    @mouseDx = 0
    @mouseDy = 0

    rect = @_canvas.getBoundingClientRect()
    @_offsleft = rect.left + document.body.scrollLeft
    @_offstop = rect.top + document.body.scrollTop

    window.onkeydown = (event) => @handleKeyDown event
    window.onkeyup = (event) => @handleKeyUp event
    window.onmousemove = (event) => @handleMouseMove event
    window.onmousedown = (event) => @handleMouseDown event
    window.onmouseup = (event) => @handleMouseUp event

  handleKeyDown: (event) ->
    @_keys[event.keyCode] = true
    #console.log event.keyCode
    return

  handleKeyUp: (event) ->
    @_keys[event.keyCode] = false
    @handleSpecialKeys(event.keyCode)
    return

  handleMouseMove: (event) ->
    x = event.pageX - @_offsleft
    y = event.pageY - @_offstop
    if @mouseX? and @mouseY?
      @mouseDx = -(@mouseX - x)
      @mouseDy = (@mouseY - y)
    @mouseX = x
    @mouseY = y

  handleMouseDown: (event) ->
    @mouseDown = true

  handleMouseUp: (event) ->
    @mouseDown = false

  handleSpecialKeys: (keyCode) ->
    if keyCode == 80 #P
      window.toggleDebug()
    if keyCode == 79 #O
      window.wireFrame = not window.wireFrame
    if keyCode == 73 #I
      window.mouseActive = not window.mouseActive
    return

  keyPressed: (keyCode) ->
    return @_keys[keyCode]

  reset: ->
    @mouseDx = 0
    @mouseDy = 0
