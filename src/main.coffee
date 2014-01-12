play_level = (name) ->
  level = new Level()
  level.load_from_file(name)

  # Load assets for this level before doing anything else
  level.assets.load( ->
    update = ->
      level.physics.update()
      level.display()
      window.game_loop = window.requestAnimationFrame(update)

    createjs.Sound.setMute(true)

    level.start_time   = new Date().getTime()
    level.current_time = 0
    level.physics.init()

    window.cancelAnimationFrame(window.game_loop)
    hide_loading()

    update()
  )

show_loading = ->
  $("#loading").show()

hide_loading = ->
  $("#loading").hide()

full_screen = ->
  window.onresize = ->
    $("#game").width($("body").width())
    $("#game").height($("body").height())
  window.onresize()

bind_select = ->
  $("#levels").on('change', ->
    show_loading()
    play_level($(this).val())
  )

select_level_from_url = ->
  level = location.search.substr(1)
  $("#levels").val(level)
  $("#levels").trigger("change")

$ ->
  bind_select()

  if location.search != ''
    select_level_from_url()
  else
    play_level($("#levels option:selected").val())

  #full_screen()
