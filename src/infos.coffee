class Infos

  constructor: (level) ->
    @level  = level
    @assets = level.assets

  parse: (xml) ->
    xml_level   = $(xml).find('level')
    @identifier = xml_level.attr('id')
    @pack_name  = xml_level.attr('levelpack')
    @pack_id    = xml_level.attr('levelpackNum')
    @r_version  = xml_level.attr('rversion')

    xml_infos    = $(xml).find('level').find('info')
    @name        = xml_infos.find('name').text()
    @description = xml_infos.find('description').text()
    @author      = xml_infos.find('author').text()
    @date        = xml_infos.find('date').text()

    xml_border = xml_infos.find('border')
    @border    = xml_border.attr('texture')

    xml_music = xml_infos.find('music')
    @music    = xml_music.attr('name')

    return this

  load_assets: ->

  display: (ctx) ->
