# Fullscreen: F to toggle, Esc to exit. Resizes renderer and adjusts zoom.

bind_fullscreen = ->
  $(document).on('fullscreenchange webkitfullscreenchange mozfullscreenchange MSFullscreenChange', ->
    r = window.xmoto_renderer
    opts = window.xmoto_options
    level = window.xmoto_level

    if document.fullscreenElement
      # Save original dimensions before resizing
      r._orig_width  = opts.width
      r._orig_height = opts.height
      r._orig_zoom   = Constants.default_scale.x

      # Get screen dimensions
      screenW = screen.width
      screenH = screen.height

      # Resize PIXI renderer to fill the screen
      r.resize(screenW, screenH)

      # Update options (used by camera for centering and AABB)
      opts.width  = screenW
      opts.height = screenH

      # Resize debug canvas if present
      debugCanvas = document.getElementById('xmoto-debug')
      if debugCanvas
        debugCanvas.width  = screenW
        debugCanvas.height = screenH

      # Adjust zoom proportionally so the game fills the screen
      ratio = Math.min(screenW / r._orig_width, screenH / r._orig_height)
      new_zoom_x =  r._orig_zoom * ratio
      new_zoom_y = -r._orig_zoom * ratio

      Constants.default_scale =
        x: new_zoom_x
        y: new_zoom_y

      # Update camera's current scale immediately for instant transition
      if level?.camera
        level.camera.scale.x = new_zoom_x
        level.camera.scale.y = new_zoom_y
    else
      # Restore original dimensions
      r.resize(r._orig_width, r._orig_height)
      opts.width  = r._orig_width
      opts.height = r._orig_height

      # Restore debug canvas
      debugCanvas = document.getElementById('xmoto-debug')
      if debugCanvas
        debugCanvas.width  = r._orig_width
        debugCanvas.height = r._orig_height

      # Restore zoom
      Constants.default_scale =
        x:  r._orig_zoom
        y: -r._orig_zoom

      # Restore camera scale
      if level?.camera
        level.camera.scale.x = r._orig_zoom
        level.camera.scale.y = -r._orig_zoom
  )

$ ->
  bind_fullscreen()
