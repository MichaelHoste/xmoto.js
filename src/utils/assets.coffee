class Assets

  constructor: ->
    @theme    = new Theme('modern.xml') # or "original.xml"

    @textures = [] # texture list
    @anims    = [] # anim list
    @effects  = [] # effect list (edge etc.)
    @moto     = [] # moto list
    @sounds   = [] # Sounds

    @resources = []

  load: (callback) ->
    PIXI.loader.reset()

    items = []
    for item in @textures
      items.push(
        id:  item
        src: "/data/Textures/Textures/#{item.toLowerCase()}"
      )
    for item in @anims
      items.push(
        id:  item
        src: "/data/Textures/Anims/#{item.toLowerCase()}"
      )
    for item in @effects
      items.push(
        id:  item
        src: "/data/Textures/Effects/#{item.toLowerCase()}"
      )
    for item in @moto
      items.push(
        id:  item
        src: "/data/Textures/Riders/#{item.toLowerCase()}.png"
      )

    for item in @remove_duplicate_textures(items)
      PIXI.loader.add(item.id, item.src)

    PIXI.loader.load((loader, resources) =>
      @resources = resources
      callback()
    )

  # Get an asset by its name ("id")
  get: (name) ->
    @resources[name].data

  remove_duplicate_textures: (array) ->
    unique = []
    for image in array
      found = false
      for unique_image in unique
        found = true if image.id == unique_image.id
      unique.push(image) if not found
    unique
