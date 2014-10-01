class window.Scene

  constructor: ->
    @_entities = [
      new MyTree
    ]

  delegateDrawGL: ->
    e.drawGL() for e in @_entities

  delegateDoLogic: (delta) ->
    e.doLogic(delta) for e in @_entities
