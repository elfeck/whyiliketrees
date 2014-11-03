class window.Scene

  constructor: ->
    @_entities = [
      new MyTree(1, [0.0, 0.0, 0.0]),
      new MyTree(0.5, [1.25, 0.0, 0.0]),
      new MyTree(0.25, [2.0, 0.0, 0.0])
    ]

  delegateDrawGL: ->
    e.drawGL() for e in @_entities

  delegateDoLogic: (delta) ->
    e.doLogic(delta) for e in @_entities
