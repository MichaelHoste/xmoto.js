class Assets

  constructor: ->
    @queue = new createjs.LoadQueue()
    @textures = [] # texture list
    @anims    = [] # anim lists
    @moto     = [] # moto list

  load: (callback) ->
    # Format list for loading
    items = []
    for item in @textures
      items.push(
        id:  item
        src: "data/Textures/Textures/#{item}.jpg"
      )
    for item in @anims
      items.push(
        id:  item
        src: "data/Textures/Anims/#{item}.png"
      )
    for item in @moto
      items.push(
        id:  item
        src: "data/Textures/Riders/#{item}.png"
      )

    @queue.addEventListener("complete", callback)
    @queue.loadManifest(items)

  # Get an asset by its name ("id")
  get: (name) ->
    @queue.getResult(name)
