class window.Input

  constructor: () ->
    @_keys = (false for [1..255])
    $(window).on "keydown", (event) => @handleKeyDown event
    $(window).on "keyup", (event) => @handleKeyUp event


  handleKeyDown: (event) ->
    @_keys[event.keyCode] = true
    #console.log event.keyCode
    return

  handleKeyUp: (event) ->
    @_keys[event.keyCode] = false
    @handleSpecialKeys(event.keyCode)
    return

  keyPressed: (keyCode) ->
    return @_keys[keyCode]

  handleSpecialKeys: (keyCode) ->
    if keyCode == 80
      window.toggleDebug()
    if keyCode == 79
      window.wireFrame = not window.wireFrame
    return
