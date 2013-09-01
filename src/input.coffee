# Disable up, down, left, right to scroll
# left: 37, up: 38, right: 39, down: 40, spacebar: 32, pageup: 33, pagedown: 34, end: 35, home: 36
keys = [37, 38, 39, 40]

preventDefault = (e) ->
  e = e || window.event
  if e.preventDefault
    e.preventDefault()
  e.returnValue = false

keydown = (e) ->
  for i in keys
    if e.keyCode == i
      preventDefault(e)
      return

disable_scroll = ->
  document.onkeydown = keydown

disable_scroll()
