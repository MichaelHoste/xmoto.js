class Assets

  constructor: ->
    @theme    = {}

    @textures = [] # texture list
    @anims    = [] # anim list
    @effects  = [] # effect list (edge etc.)
    @moto     = [] # moto list
    @sounds   = [] # Sounds

    @resources = {}

  parse_theme: (filename, callback) ->
    # extend to keep the same pointer to @theme that is already in other objects
    @theme = $.extend(@theme,
      new Theme('modern.xml', callback)
    )

  load: (callback) ->
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
        src: "/data/Textures/Riders/#{item.toLowerCase()}"
      )

    items = _.uniqBy(items, 'id');
    urls  = _.map(items, (item) -> item.src)

    PIXI.Assets.load(urls).then( =>
      for item in items
        @resources[item.id] = { url: item.src }

      callback()
    )

  # Get an asset by its name ("id")
  get: (name) ->
    @resources[name].data

  get_url: (name) ->
    @resources[name].url
