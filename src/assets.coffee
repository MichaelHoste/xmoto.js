class Assets

  constructor: ->
    @queue = new createjs.LoadQueue()
    @list     = [] # complete list of assets
    @textures = [] # texture list
    @anims    = [] # anim lists

  # Load a batch of textures in this format [{ id: "", src: ""}, {...}]
  load: (items, callback) ->
    for item in items
      @list.push(item.id)

    @queue.addEventListener("complete", callback)
    @queue.loadManifest(items)

  # Load textures for a specific level
  load_for_level: (level, callback) ->
    # Sky (Textures)
    @list    .push(level.sky.name)
    @textures.push(level.sky.name)

    # Borders
    @list    .push('dirt')
    @textures.push('dirt')

    # Blocks (Textures)
    for block in level.blocks
      @list    .push(block.usetexture.id)
      @textures.push(block.usetexture.id)

    # Sprites (Anims)
    for entity in level.entities
      if entity.type_id == 'Sprite'
        for param in entity.params
          if param.name == 'name'
            @list .push(param.value)
            @anims.push(param.value)

    # End of level
    for entity in level.entities
      if entity.type_id == 'EndOfLevel'
        @list .push('flower00')
        @anims.push('flower00')

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
