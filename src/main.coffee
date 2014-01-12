play_level = (name) ->
  level = new Level()
  level.load_from_file(name)

  # Load assets for this level before doing anything else
  level.assets.load( ->
    update = ->
      update_physics()
      level.display()
      window.game_loop = window.requestAnimationFrame(update)

    update_physics = ->
      while (new Date()).getTime() - last_step > physics_step
        level.input.move()
        level.world.Step(1.0/60.0, 10, 10)
        level.world.ClearForces()
        last_step += physics_step
        level.replay.add_frame()

    createjs.Sound.setMute(true)

    last_step    = new Date().getTime()
    physics_step = 1000.0/60.0

    level.start_time   = new Date().getTime()
    level.current_time = 0

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
