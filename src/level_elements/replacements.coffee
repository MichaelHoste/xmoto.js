class Replacements

  constructor: (level) ->
    @level  = level
    @assets = level.assets

    @sprites = {} # old_name => new_name
    @sounds  = {} # old_name => new_name

  parse: (xml) ->
    xml_replacements = $(xml).find('theme_replacements')

    for sprite_replacement in xml_replacements.find('sprite_replacement')
      old_name = $(sprite_replacement).attr('old_name')
      new_name = $(sprite_replacement).attr('new_name')
      @sprites[old_name] = new_name

    for sound_replacement in xml_replacements.find('sound_replacement')
      old_name = $(sound_replacement).attr('old_name')
      new_name = $(sound_replacement).attr('new_name')
      @sounds[old_name] = new_name
