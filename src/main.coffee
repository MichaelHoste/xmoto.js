play_level = (name) ->
  level = new Level()
  level.load_from_file(name)
  #level.pause()

  # Load assets for this level before doing anything else
  level.assets.load( ->
    createjs.Sound.setMute(true)
    level.animation_frame_update() # request animation frame
    hide_loading()

    # display at least one time the buffer in case the level is started in pause mode
    if level.is_beeing_displayed() == false
      level.display()
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
