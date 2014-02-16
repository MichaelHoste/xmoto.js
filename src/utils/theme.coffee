class Theme

  constructor: (file_name) ->
    @sprites  = []
    @edges    = []
    @textures = []

    $.ajax({
      type:     "GET",
      url:      "/data/Themes/#{file_name}",
      dataType: "xml",
      success:  @load_theme
      async:    false
      context:  @
    })

  load_theme: (xml) ->
    xml_sprites = $(xml).find('sprite')

    for xml_sprite in xml_sprites

      if $(xml_sprite).attr('type') == 'Entity'
        @sprites[$(xml_sprite).attr('name')] =
          file:      $(xml_sprite).attr('file')
          file_base: $(xml_sprite).attr('fileBase')
          file_ext:  $(xml_sprite).attr('fileExtension')
          size:
            width:   parseFloat($(xml_sprite).attr('width'))
            height:  parseFloat($(xml_sprite).attr('height'))
          center:
            x:       parseFloat($(xml_sprite).attr('centerX'))
            y:       parseFloat($(xml_sprite).attr('centerY'))
          frames:    $(xml_sprite).find('frame').length
          delay:     parseFloat($(xml_sprite).attr('delay'))

      else if $(xml_sprite).attr('type') == 'EdgeEffect'
        @edges[$(xml_sprite).attr('name').toLowerCase()] =
          file:  $(xml_sprite).attr('file').toLowerCase()
          scale: parseFloat($(xml_sprite).attr('scale'))
          depth: parseFloat($(xml_sprite).attr('depth'))

      else if $(xml_sprite).attr('type') == 'Texture'
        @textures[$(xml_sprite).attr('name').toLowerCase()] =
          file:      $(xml_sprite).attr('file').toLowerCase() if $(xml_sprite).attr('file')
          file_base: $(xml_sprite).attr('fileBase')
          file_ext:  $(xml_sprite).attr('fileExtension')
          frames:    $(xml_sprite).find('frame').length
          delay:     parseFloat($(xml_sprite).attr('delay'))

  sprite_params: (name) ->
    @sprites[name]

  edge_params: (name) ->
    @edges[name]

  texture_params: (name) ->
    @textures[name]
