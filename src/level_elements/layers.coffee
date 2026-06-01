class Layers

  constructor: (level) ->
    @level  = level
    @assets = level.assets
    @list   = []

  parse: (xml) ->
    xml_layers = $(xml).find('layeroffsets layeroffset')

    for xml_layer in xml_layers
      layer =
        x:          parseFloat($(xml_layer).attr('x'))
        y:          parseFloat($(xml_layer).attr('y'))
        frontlayer: $(xml_layer).attr('frontlayer') == 'true'
        name:       $(xml_layer).attr('name')

      @list.push(layer)

    return this

  init: ->

  display: (ctx) ->
