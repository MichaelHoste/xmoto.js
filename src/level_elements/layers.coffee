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

    # Parallax layers — each has its own world-transform container (zoom-independent)
    @parallax_containers = [] # direct children of stage: world-to-screen transform (scale, Y-flip, canvas centre)
    @parallax            = [] # translate containers inside their container (parallax camera position)

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

    @scale_layer.label     = 'scale'
    @translate_layer.label = 'translate'

  # Static level layers
  init_static_layers: ->
    @static_background = new PIXI.Container() # entity.z < 0 or blocks with background="true"
    @static_level      = new PIXI.Container() # entity.z = 0 or blocks with classic blocks
    @static_foreground = new PIXI.Container() # entity.z > 0 or blocks with islayer="true" and no layerid

    @static_background.label = 'static-background'
    @static_level.label      = 'static-level'
    @static_foreground.label = 'static-foreground'

  # Each parallax layer gets its own world-transform container so camera zoom doesn't apply
  init_parallax_layers: ->
    for parallax_data in @list
      container = new PIXI.Container()
      content   = new PIXI.Container()

      container.label = "#{parallax_data.name}-container"
      content.label   = parallax_data.name

      container.addChild(content)

      @parallax_containers.push(container)
      @parallax.push(content)

  assemble_layers: ->
    ### Structure is like this
    Root
     - Sky
     - n parallax_container with frontlayer="false"   (direct children of Root, zoom-independent)
         -> parallax (blocks go here)
     - Scale
       -> Translate
         -> static-background
         -> static-level
         -> static-foreground
     - n parallax_container with frontlayer="true"
         -> parallax
    ###

    for parallax, i in @list
      if !parallax.frontlayer
        @level.stage.addChild(@parallax_containers[i])

    @level.stage.addChild(@scale_layer)
    @scale_layer.addChild(@translate_layer)
    @translate_layer.addChild(@static_background)
    @translate_layer.addChild(@static_level)
    @translate_layer.addChild(@static_foreground)

    for parallax, i in @list
      if parallax.frontlayer
        @level.stage.addChild(@parallax_containers[i])

  layer_for_block: (block) ->
    if block.position.background
      @static_background
    else if block.position.islayer
      if block.position.layerid?
        @parallax[block.position.layerid] || @static_level
      else
        @static_foreground
    else
      @static_level

  update: ->
