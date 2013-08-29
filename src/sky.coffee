class Sky

  constructor: (level) ->
    @level  = level
    @assets = level.assets

  parse: (xml) ->
    xml_sky    = $(xml).find('level info sky')
    @name      = xml_sky.text().toLowerCase()
    @color_r   = parseInt(xml_sky.attr('color_r'))
    @color_g   = parseInt(xml_sky.attr('color_g'))
    @color_b   = parseInt(xml_sky.attr('color_b'))
    @color_a   = parseInt(xml_sky.attr('color_a'))
    @zoom      = parseFloat(xml_sky.attr('zoom'))
    @offset    = parseFloat(xml_sky.attr('offset'))

    return this

  init_assets: ->
    @assets.textures.push(@name)

  display: (ctx) ->
    ctx.drawImage(@assets.get(@name),
                  @level.limits.screen.left,
                  @level.limits.screen.bottom,
                  @level.limits.size.x,
                  @level.limits.size.y)
