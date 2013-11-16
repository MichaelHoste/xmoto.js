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

    @name = 'sky1' if @name == ''

    return this

  init: ->
    @assets.textures.push(@name)

  display: (ctx) ->
    ctx.beginPath()
    ctx.moveTo(@level.limits.screen.left + @level.limits.size.x, @level.limits.screen.bottom)
    ctx.lineTo(@level.limits.screen.left + @level.limits.size.x, @level.limits.screen.bottom + @level.limits.size.y)
    ctx.lineTo(@level.limits.screen.left,                        @level.limits.screen.bottom + @level.limits.size.y)
    ctx.lineTo(@level.limits.screen.left,                        @level.limits.screen.bottom)
    ctx.closePath()

    ctx.save()
    ctx.scale(1.0 / 15.0, -1.0 / 15.0)
    ctx.fillStyle = ctx.createPattern(@assets.get(@name), "repeat")
    ctx.fill()
    ctx.restore()
