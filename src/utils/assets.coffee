class Assets

  constructor: ->
    @queue = new createjs.LoadQueue()
    #@theme = new Theme('modern.xml')
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
        id:   item
        src:  "data/Textures/Anims/#{item}.png"
#        data: @theme.sprite_params(item)
      )
    for item in @moto
      items.push(
        id:  item
        src: "data/Textures/Riders/#{item}.png"
      )

    items = @remove_duplicate_textures(items)

    @queue.addEventListener("complete", callback)
    @queue.loadManifest(items)

  # Get an asset by its name ("id")
  get: (name) ->
    @queue.getResult(name)

  remove_duplicate_textures: (array) ->
    unique = []
    for image in array
      found = false
      for unique_image in unique
        found = true if image.id == unique_image.id
      unique.push(image) if not found

    unique

