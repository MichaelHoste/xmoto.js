class Layers

  constructor: (level) ->
    @level  = level
    @assets = level.assets
    @list   = []

    # Camera layers
    @scale_layer     = undefined
    @translate_layer = undefined

    # Static layers
    @static_background = undefined
    @static_level      = undefined
    @static_foreground = undefined

    # Parallax layers — each has its own scale/translate containers
    @parallax_scale_layers     = [] # direct children of stage for scaling
    @parallax_translate_layers = [] # translate containers inside their container with parallax values
    @parallax_layers           = [] # parallax blocks

  parse: (xml) ->
    xml_layers = $(xml).find('layeroffsets layeroffset')

    for xml_layer, i in xml_layers
      layer =
        x:          parseFloat($(xml_layer).attr('x'))
        y:          parseFloat($(xml_layer).attr('y'))
        frontlayer: $(xml_layer).attr('frontlayer') == 'true'

      layer.name = $(xml_layer).attr('name') || "parallax-#{if layer.frontlayer then 'front' else 'back'}-#{i}"

      @list.push(layer)

    return this

  init: ->
    @init_camera_layers()
    @init_static_layers()
    @init_parallax_layers()

    @assemble_layers()

  # Layers for easier camera control
  init_camera_layers: ->
    @scale_layer     = new PIXI.Container()
    @translate_layer = new PIXI.Container()

    @scale_layer.label     = 'level - scale'
    @translate_layer.label = 'level - translate'

  # Static level layers
  init_static_layers: ->
    @static_background = new PIXI.Container() # entity.z < 0 or blocks with background="true"
    @static_level      = new PIXI.Container() # entity.z = 0 or blocks with classic blocks
    @static_foreground = new PIXI.Container() # entity.z > 0 or blocks with islayer="true" and no layerid

    @static_background.label = 'background'
    @static_level.label      = 'level'
    @static_foreground.label = 'foreground'

  init_parallax_layers: ->
    for parallax_data in @list
      scale_layer      = new PIXI.Container()
      translate_layer  = new PIXI.Container()
      parallax_layer   = new PIXI.Container()

      scale_layer.label       = "#{parallax_data.name} - scale"
      translate_layer.label   = "#{parallax_data.name} - translate"
      parallax_layer.label    = "#{parallax_data.name}"
      parallax_layer.parallax = true

      scale_layer.addChild(translate_layer)
      translate_layer.addChild(parallax_layer)

      @parallax_scale_layers.push(scale_layer)
      @parallax_translate_layers.push(translate_layer)
      @parallax_layers.push(parallax_layer)

  assemble_layers: ->
    ### Structure is like this
    Root
     - Sky
     - n Scale > Translate > Parallax layers with frontlayer="false"
     - Scale
       -> Translate
         -> static-background
         -> static-level
         -> static-foreground
     - n Scale > Translate > Parallax layers with frontlayer="true"
    ###

    for parallax, i in @list
      if !parallax.frontlayer
        @level.stage.addChild(@parallax_scale_layers[i])

    @level.stage.addChild(@scale_layer)
    @scale_layer.addChild(@translate_layer)
    @translate_layer.addChild(@static_background)
    @translate_layer.addChild(@static_level)
    @translate_layer.addChild(@static_foreground)

    for parallax, i in @list
      if parallax.frontlayer
        @level.stage.addChild(@parallax_scale_layers[i])

  layer_for_block: (block) ->
    if block.position.background
      @static_background
    else if block.position.islayer
      if block.position.layerid?
        @parallax_layers[block.position.layerid] || @static_level # TODO should "|| @static_level" be removed?
      else
        @static_foreground
    else
      @static_level

  update: ->
