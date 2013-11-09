class Assets

  constructor: ->
    @queue    = new createjs.LoadQueue()
    @theme    = new Theme('modern.xml')

    @textures = [] # texture list
    @anims    = [] # anim list
    @effects  = [] # effect list (edge etc.)
    @moto     = [] # moto list
    @sounds   = [] # Sounds

  load: ->
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

    #createjs.Sound.registerSound(
    #  id:  "PickUpStrawberry"
    #  src: "data/Sounds/PickUpStrawberry.ogg"
    #)
#
    #createjs.Sound.registerSound(
    #  id:  "Headcrash"
    #  src: "data/Sounds/Headcrash.ogg"
    #)
#
    #createjs.Sound.registerSound(
    #  id:  "EndOfLevel"
    #  src: "data/Sounds/EndOfLevel.ogg"
    #)

    #for rpm in ['0000', '1000', '2000', '3000', '4000', '5000', '6000']
    #  createjs.Sound.registerSound(
    #    id:  "engine_#{rpm}"
    #    src: "data/Sounds/engine_#{rpm}.ogg"
    #  )

    items = @remove_duplicate_textures(items)

    for item in items
      $("#assets").append("<img id=\"#{item.id}\" src=\"#{item.src}\"/>")

    items = []

    console.log("salut fin de chargement ")

    #@queue.addEventListener("complete", callback)
    #@queue.loadManifest(items)

    console.log("fin")

  # Get an asset by its name ("id")
  get: (name) ->
    if name.length >0
      document.getElementById(name)
    else
      document.getElementById('cog2')

  remove_duplicate_textures: (array) ->
    unique = []
    for image in array
      found = false
      for unique_image in unique
        found = true if image.id == unique_image.id
      unique.push(image) if not found

    unique

