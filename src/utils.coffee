_id = 1
window.get_uid = ->
  _id++
  return _id - 1

window.dprint = (msg) ->
  time = new Date()
  h = time.getHours() + ""
  m = time.getMinutes() + ""
  s = time.getSeconds() + ""
  if h.length == 1
    h = "0" + h
  if m.length == 1
    m = "0" + m
  if s.length == 1
    s = "0" + s
  #line = "[" + h + ":" + m + ":" + s  + "]  "
  line = ""
  $("#console").append("\n" + line + msg)
  $("#console").scrollTop($("#console").scrollHeight)
  return

window.setInfo = (i, msg) ->
  $("#info" + i).text(msg)
  return

window.toggleDebug = ->
  window.debug = not window.debug
  if window.debug
    $("#console").show()
    $("#info1").show()
    $("#info2").show()
  else
    $("#console").hide()
    $("#info1").hide()
    $("#info2").hide()
  return
