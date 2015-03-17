_id = 1
window.getuid = ->
  _id++
  return _id - 1

window._knownLines = []

window.isFloatZero = (f) ->
  return Math.abs(f) < 0.000001

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
    line = "[" + h + ":" + m + ":" + s  + "]  " + msg + "\n"
    console.log msg if consoleLog
    cons = document.getElementById("console")
    cons.innerHTML += (line)
    cons.scrollTop = cons.scrollHeight
    window._knownLines.push msg
    return

window.dbgSetInfo = (i, msg) ->
  return if not window.debug
  document.getElementById("info" + i).innerHTML = msg
  return

window.toggleDebug = ->
  window.debug = not window.debug
  window.wireFrame = false
  infCount = 7
  if window.debug
    document.getElementById("console").style.display = "block"
    for i in [1..infCount]
      document.getElementById("info" + i).style.color = "#666666"
  else
    document.getElementById("console").style.display = "none"
    for i in [1..infCount]
      document.getElementById("info" + i).style.color = "transparent"
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

window.arrayEqual = (a, b) ->
  a.length is b.length and a.every (elem, i) -> elem is b[i]
