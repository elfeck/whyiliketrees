class window.Scene

  constructor: ->
    @_entities = [
      new MyTree(5, [0.0, 0.0, 0.0]),
      new MyTree(10, [6.0, 0.0, 0.0])
    ]

  delegateDrawGL: ->
    e.drawGL() for e in @_entities

  delegateDoLogic: (delta) ->
    e.doLogic(delta) for e in @_entities
