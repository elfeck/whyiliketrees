_id = 1
window.get_uid = ->
  _id++
  return _id - 1

window._knownLines = []

window.dprint = (msg) ->
  if not (msg in window._knownLines)
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
    console = document.getElementById("console")
    console.innerHTML += ("\n" + line + msg)
    console.scrollTop = console.scrollHeight
    window._knownLines.push msg
    return

window.setInfo = (i, msg) ->
  document.getElementById("info" + i).innerHTML = msg
  return

window.toggleDebug = ->
  window.debug = not window.debug
  window.wireFrame = false
  if window.debug
    document.getElementById("console").style.display = "block"
    document.getElementById("info1").style.color = "#666666"
    document.getElementById("info2").style.color = "#666666"
    document.getElementById("info3").style.color = "#666666"
  else
    document.getElementById("console").style.display = "none"
    document.getElementById("info1").style.color = "transparent"
    document.getElementById("info2").style.color = "transparent"
    document.getElementById("info3").style.color = "transparent"
  return

window.getShaderAttributes = (vertSrc) ->
  lines = vertSrc.split(";")
  lines = lines.filter (l) -> l.indexOf("attribute") > -1
  for i in [0..lines.length-1]
    lines[i] = lines[i].replace "attribute ", ""
    lines[i] = lines[i].replace "float ", ""
    lines[i] = lines[i].replace "vec2 ", ""
    lines[i] = lines[i].replace "vec3 ", ""
    lines[i] = lines[i].replace "vec4 ", ""
    lines[i] = lines[i].replace ";", ""
    lines[i] = lines[i].replace " ", ""
    lines[i] = lines[i].replace "\n", ""
  return lines
