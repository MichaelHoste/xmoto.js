class Assets

  constructor: ->
    @queue    = new createjs.LoadQueue()
    @theme    = new Theme('modern.xml')

    @textures = [] # texture list
    @anims    = [] # anim list
    @effects  = [] # effect list (edge etc.)
    @moto     = [] # moto list
    @sounds   = [] # Sounds

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
      )
    for item in @effects
      items.push(
        id:  item
        src: "data/Textures/Effects/#{item}" # In /Effects/, we can find png AND jpg. The extension is on the modern.xml file
      )
    for item in @moto
      items.push(
        id:  item
        src: "data/Textures/Riders/#{item}.png"
      )

    createjs.Sound.registerSound(
      id:  "PickUpStrawberry"
      src: "data/Sounds/PickUpStrawberry.ogg"
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

