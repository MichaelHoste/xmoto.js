play_level = (name) ->
  level = new Level()
  #level.load_from_file(name)

  level.load_from_file("l1.lvl")
  #level.load_as_replay("replay_1383574.rpl")

  #level.load_from_file("l2813.lvl")
  #level.load_as_replay("credits.rpl")

  #level.load_from_file("l24.lvl")
  #level.load_as_replay("replay_1436520.rpl")

  # Load assets for this level before doing anything else
  level.assets.load( ->
    createjs.Sound.setMute(true)

    last_step    = new Date().getTime()
    physics_step = 1000.0/60.0

    update_physics = ->
      while (new Date()).getTime() - last_step > physics_step
        level.input.move()
        level.world.Step(1.0/60.0, 10, 10)
        level.world.ClearForces()
        last_step += physics_step

    update = ->
      update_physics()
      level.display(false)
      window.requestAnimationFrame(update)

    update()

    hide_loading()
  )

show_loading = ->
  $(".xmoto-loading").show()

hide_loading = ->
  $(".xmoto-loading").hide()

full_screen = ->
  window.onresize = ->
    $("#game").width($("body").width())
    $("#game").height($("body").height())
  window.onresize()

$ ->
  play_level($("#levels option:selected").val())
  
  $("#levels").on('change', ->
    show_loading()
    clearInterval(window.game_loop)
    play_level($(this).val())
  )

  #full_screen()
