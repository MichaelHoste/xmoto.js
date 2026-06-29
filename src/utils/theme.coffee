class Theme

  constructor: (filename, callback) ->
    @filename = filename
    @callback = callback

    @sprites  = []
    @edges    = []
    @textures = []

    $.ajax({
      type:     "GET",
      url:      "/data/Themes/#{filename}",
      dataType: "xml",
      success:  @load_theme
      context:  @
    })

  load_theme: (xml) ->
    xml_sprites = $(xml).find('sprite')

    for xml_sprite in xml_sprites
      name = $(xml_sprite).attr('name').toLowerCase()

      if $(xml_sprite).attr('type') == 'Entity'
        @sprites[name] =
          file:           $(xml_sprite).attr('file')
          file_base:      $(xml_sprite).attr('fileBase')
          file_extension: $(xml_sprite).attr('fileExtension')
          size:
            width:   parseFloat($(xml_sprite).attr('width'))
            height:  parseFloat($(xml_sprite).attr('height'))
          center:
            x:       parseFloat($(xml_sprite).attr('centerX'))
            y:       parseFloat($(xml_sprite).attr('centerY'))
          frames:    $(xml_sprite).find('frame').length
          delay:     parseFloat($(xml_sprite).attr('delay'))

      else if $(xml_sprite).attr('type') == 'EdgeEffect'
        @edges[name] =
          file:  $(xml_sprite).attr('file')
          scale: parseFloat($(xml_sprite).attr('scale'))
          depth: parseFloat($(xml_sprite).attr('depth'))

      else if $(xml_sprite).attr('type') == 'Texture'
        frames   = $(xml_sprite).find('frame').length
        existing = @textures[name]

        # The same texture sometimes exists as both animated an non-animated (like "Lava", "Water1", "Water2", ...)
        # => Always keep the animated one
        if !existing || existing.frames == 0
          @textures[name] =
            file:           $(xml_sprite).attr('file')
            file_base:      $(xml_sprite).attr('fileBase')
            file_extension: $(xml_sprite).attr('fileExtension')
            frames:         frames
            delay:          parseFloat($(xml_sprite).attr('delay'))

    @callback()

  sprite_params: (name) ->
    @sprites[name.toLowerCase()]

  edge_params: (name) ->
    @edges[name.toLowerCase()]

  texture_params: (name) ->
    @textures[name.toLowerCase()]
