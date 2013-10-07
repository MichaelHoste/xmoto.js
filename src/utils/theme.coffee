class Theme

  constructor: (file_name) ->
    @sprites = []

    $.ajax({
      type:     "GET",
      url:      "data/Themes/#{file_name}",
      dataType: "xml",
      success:  @load_theme
      async:    false
      context:  @
    })

  load_theme: (xml) ->
    xml_sprites = $(xml).find('sprite')

    for xml_sprite in xml_sprites
      if $(xml_sprite).attr('type') == 'Entity'
        @sprites[$(xml_sprite).attr('name').toLowerCase()] =
          size:
            width: parseFloat($(xml_sprite).attr('width'))
            height: parseFloat($(xml_sprite).attr('height'))
          center:
            x: parseFloat($(xml_sprite).attr('centerX'))
            y: parseFloat($(xml_sprite).attr('centerY'))

  sprite_params: (name) ->
    @sprites[name]

