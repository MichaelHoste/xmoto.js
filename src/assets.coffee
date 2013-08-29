class Assets

  constructor: ->
    @queue = new createjs.LoadQueue()
    @list     = [] # complete list of assets
    @textures = [] # texture list
    @anims    = [] # anim lists

  # Load textures for a specific level
  load_for_level: (level, callback) ->
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

    @queue.addEventListener("complete", callback)
    @queue.loadManifest(items)

  # Get an asset by its name ("id")
  get: (name) ->
    @queue.getResult(name)
