class LayerOffsets

  constructor: (level) ->
    @level  = level
    @assets = level.assets
    @list   = []

  parse: (xml) ->
    xml_layer_offsets = $(xml).find('layeroffsets layeroffset')

    for xml_layer_offset in xml_layer_offsets
      layer_offset =
        x:           parseFloat($(xml_layer_offset).attr('x'))
        y:           parseFloat($(xml_layer_offset).attr('y'))
        front_layer: $(xml_layer_offset).attr('frontlayer')

      @list.push(layer_offset)

    return this

  init: ->

  display: (ctx) ->
