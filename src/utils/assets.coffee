class Assets

  constructor: ->
    @theme = undefined

    @textures = [] # texture list
    @anims    = [] # anim list
    @effects  = [] # effect list (edge etc.)
    @sounds   = [] # Sound effects needed on every level
    @moto     = [] # moto list

    @resources = {}

  parse_theme: (callback) ->
    @theme = new Theme("modern.xml", callback)

  load: (callback) ->
    items = []
    for item in @textures
      items.push(
        id:  item
        src: "/data/Textures/Textures/#{item}"
      )
    for item in @anims
      items.push(
        id:  item
        src: "/data/Textures/Anims/#{item}"
      )
    for item in @effects
      items.push(
        id:  item
        src: "/data/Textures/Effects/#{item}"
      )
    for item in @sounds
      items.push(
        id: item,
        src: "/data/Sounds/#{item}"
      )
    for item in @moto
      items.push(
        id:  item
        src: "/data/Textures/Riders/#{item}"
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
