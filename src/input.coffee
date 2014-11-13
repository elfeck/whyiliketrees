class window.Input

  constructor: () ->
    @_keys = (false for [1..255])
    @_canvas = $("#canvas")

    @mouseX = undefined
    @mouseY = undefined

    @mouseDx = 0
    @mouseDy = 0

    $(window).on "keydown", (event) => @handleKeyDown event
    $(window).on "keyup", (event) => @handleKeyUp event
    $(window).on "mousemove", (event) => @handleMouse event

  handleKeyDown: (event) ->
    @_keys[event.keyCode] = true
    #console.log event.keyCode
    return

  handleKeyUp: (event) ->
    @_keys[event.keyCode] = false
    @handleSpecialKeys(event.keyCode)
    return

  handleMouse: (event) ->
    x = event.pageX - @_canvas.offset().left
    y = event.pageY - @_canvas.offset().top
    if @mouseX? and @mouseY?
      @mouseDx = -(@mouseX - x)
      @mouseDy = (@mouseY - y)
    @mouseX = x
    @mouseY = y

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
