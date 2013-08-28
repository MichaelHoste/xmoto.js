class window.Sky

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

  display: (ctx) ->
    ctx.drawImage(@assets.get(@name),
                  @level.screen_limits.left,
                  @level.screen_limits.bottom,
                  @level.size.x,
                  @level.size.y)
