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
    @init_containers()

  init_containers: ->
    @scale_container      = new PIXI.Container()
    @translate_container  = new PIXI.Container()
    @negative_z_container = new PIXI.Container()
    @neutral_z_container  = new PIXI.Container()
    @positive_z_container = new PIXI.Container()

    @scale_container.label      = 'scale'
    @translate_container.label  = 'translate'
    @negative_z_container.label = 'negative_z'
    @neutral_z_container.label  = 'neutral_z'
    @positive_z_container.label = 'positive_z'

    @level.stage.addChild(@scale_container)
    @scale_container.addChild(@translate_container)
    @translate_container.addChild(@negative_z_container)
    @translate_container.addChild(@neutral_z_container)
    @translate_container.addChild(@positive_z_container)

  update: ->
