class Limits

  constructor: (level) ->
    @level  = level
    @assets = level.assets

  parse: (xml) ->
    xml_limits = $(xml).find('limits')

    # CAREFUL ! The limits on files are not real, some polygons could
    # be in the limits (maybe it's the limits where the player can go)

    @screen =
      left:   parseFloat(xml_limits.attr('left'))   * 1.15
      right:  parseFloat(xml_limits.attr('right'))  * 1.15
      top:    parseFloat(xml_limits.attr('top'))    * 1.15
      bottom: parseFloat(xml_limits.attr('bottom')) * 1.15

    @player =
      left:   parseFloat(xml_limits.attr('left'))
      right:  parseFloat(xml_limits.attr('right'))
      top:    parseFloat(xml_limits.attr('top'))
      bottom: parseFloat(xml_limits.attr('bottom'))

    @size =
      x: @screen.right - @screen.left
      y: @screen.top   - @screen.bottom

  display: (ctx) ->
    ctx.beginPath()
    ctx.moveTo(@screen.left, @screen.top   )
    ctx.lineTo(@screen.left, @screen.bottom)
    ctx.lineTo(@player.left, @screen.bottom)
    ctx.lineTo(@player.left, @screen.top   )
    ctx.closePath()

    ctx.save()
    ctx.scale(1.0 / @level.scale.x, 1.0 / @level.scale.y)
    ctx.fillStyle = ctx.createPattern(@assets.get('dirt'), "repeat")
    ctx.fill()
    ctx.restore()

    ctx.beginPath()
    ctx.moveTo(@screen.right, @screen.top   )
    ctx.lineTo(@screen.right, @screen.bottom)
    ctx.lineTo(@player.right, @screen.bottom)
    ctx.lineTo(@player.right, @screen.top   )
    ctx.closePath()

    ctx.save()
    ctx.scale(1.0 / @level.scale.x, 1.0 / @level.scale.y)
    ctx.fillStyle = ctx.createPattern(@assets.get('dirt'), "repeat")
    ctx.fill()
    ctx.restore()

    ctx.beginPath()
    ctx.moveTo(@player.right, @player.bottom)
    ctx.lineTo(@player.left,  @player.bottom)
    ctx.lineTo(@player.left,  @screen.bottom)
    ctx.lineTo(@player.right, @screen.bottom)
    ctx.closePath()

    ctx.save()
    ctx.scale(1.0 / @level.scale.x, 1.0 / @level.scale.y)
    ctx.fillStyle = ctx.createPattern(@assets.get('dirt'), "repeat")
    ctx.fill()
    ctx.restore()
