# Apparently needed
(($) -> ) jQuery

DISPLAY_WIDTH = 600
DISPLAY_HEIGHT = 400

# OpenGL Context
GL = undefined

initGL = (canvas) ->
  canvas.width DISPLAY_WIDTH
  canvas.height DISPLAY_HEIGHT
  GL = canvas[0].getContext "experimental-webgl"

$ ->
  initGL $("#canvas")
