class Script

  constructor: (level) ->
    @level  = level
    @assets = level.assets

  parse: (xml) ->
    xml_script = $(xml).find('script')
    @code = xml_script.text()

    return this

  init_assets: ->

  display: (ctx) ->
