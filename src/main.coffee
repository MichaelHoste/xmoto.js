play_level = (name) ->
  alert('play level')
  alert("play level 2")
  level = new Level()
  alert("new level")
  level.load_from_file(name)

  # Load assets for this level before doing anything else
  alert("avant assets")
  level.assets.load()
  alert("assets charges")
  setTimeout( (-> go()), 3000)

  go = ->
    #createjs.Sound.setMute(true)
    alert("debut du go")

    update = ->
      level.input.move_moto()

      #level.engine_sound.play()
      level.world.Step(1.0 / 30.0, 20, 20)
      level.world.Step(1.0 / 30.0, 20, 20)
      level.world.ClearForces()
      level.display(false)

    # Render 2D environment
    window.game_loop = setInterval(update, 1000 / 15)

    hide_loading()

show_loading = ->
  $(".xmoto-loading").show()

hide_loading = ->
  $(".xmoto-loading").hide()

$ ->
  window.screen.mozLockOrientation('landscape-primary') if window.screen.mozLockOrientation
  play_level($("#levels option:selected").val())

  $("#levels").on('change', ->
    show_loading()
    clearInterval(window.game_loop)
    play_level($(this).val())
  )

  $("canvas").width($("body").width())
  $("canvas").height($("body").height())

  window.onresize = ->
    $("canvas").width($("body").width())
    $("canvas").height($("body").height())
