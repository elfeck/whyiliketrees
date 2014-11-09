class window.Scene

  constructor: ->
    @_entities = [
      new World
      #new TestSpikes
    ]

  delegateDrawGL: ->
    e.drawGL() for e in @_entities
    return

  delegateDoLogic: (delta) ->
    e.doLogic delta for e in @_entities
    return
