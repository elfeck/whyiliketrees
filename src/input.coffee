class window.Input

  constructor: () ->
    @keys = (false for [1..255])
    @canvas = document.getElementById "canvas"

    @mouseX = undefined
    @mouseY = undefined
    @mouseDown = false

    @mouseDx = 0
    @mouseDy = 0

    rect = @canvas.getBoundingClientRect()
    @offsleft = rect.left + document.body.scrollLeft
    @offstop = rect.top + document.body.scrollTop

    window.onkeydown = (event) => @handleKeyDown event
    window.onkeyup = (event) => @handleKeyUp event
    window.onmousemove = (event) => @handleMouseMove event
    window.onmousedown = (event) => @handleMouseDown event
    window.onmouseup = (event) => @handleMouseUp event

  handleKeyDown: (event) ->
    if event.keyCode == 32
      event.preventDefault()
    @keys[event.keyCode] = true
    #console.log event.keyCode
    return

  handleKeyUp: (event) ->
    @keys[event.keyCode] = false
    @handleSpecialKeys(event.keyCode)
    return

  handleMouseMove: (event) ->
    x = event.pageX - @offsleft
    y = event.pageY - @offstop
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
    return @keys[keyCode]

  reset: ->
    @mouseDx = 0
    @mouseDy = 0
