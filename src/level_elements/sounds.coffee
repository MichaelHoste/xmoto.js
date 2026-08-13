class Sounds

  constructor: (level) ->
    @level  = level
    @assets = level.assets

    @list = []

  parse: (xml) ->
    # Sounds available to all levels
    sound_names = ['EndOfLevel', 'Headcrash']

    # Only when strawberries (or equivalent) in the level
    if $(xml).find('entity[typeid="Strawberry"]').length
      sound_names.push('PickUpStrawberry')

    # Only when checkpoint in the level
    if $(xml).find('entity[typeid="Checkpoint"]').length
      sound_names.push('Checkpoint')

    for sound_name in sound_names
      # theme_replacements in level XML
      if @level.replacements.sprites[name]
        sound_name = @level.replacements.sprites[name]

      # get infos (file) from theme
      theme_sound = @assets.theme.sound_params(sound_name)

      @list.push(theme_sound)

  load_assets: ->
    for sound in @list
      @assets.sounds.push(sound.file)

  init: ->
    ;

  update: ->
    ;
