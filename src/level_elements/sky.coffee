class Sky

  constructor: (level) ->
    @level  = level
    @assets = level.assets
    @theme  = @assets.theme

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
    @file_name = @theme.texture_params(@name).file

    return this

  init: ->
    @assets.textures.push(@file_name)

  display: ->
    ctx = @level.ctx

    ctx.beginPath()
    ctx.moveTo(@level.canvas_width, @level.canvas_height)
    ctx.lineTo(0,                   @level.canvas_height)
    ctx.lineTo(0,                   0)
    ctx.lineTo(@level.canvas_width, 0)
    ctx.closePath()

    if Constants.debug
      ctx.fillStyle = "#FFFFFF"
      ctx.fill()
    else
      ctx.save()
      ctx.scale(4.0, 4.0)
      ctx.translate(-@level.object_to_follow().position().x*4, @level.object_to_follow().position().y*2)
      ctx.fillStyle = ctx.createPattern(@assets.get(@file_name), "repeat")
      ctx.fill()
      ctx.restore()
