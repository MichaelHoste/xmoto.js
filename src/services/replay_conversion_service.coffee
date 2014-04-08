# Convert replay from object to minified string to be send to the server
# And vice versa

class ReplayConversionService

  @inputs_to_string: (inputs) ->
    string = ''

    for key in [ 'up_down', 'up_up', 'down_down', 'down_up', 'left_down',
                 'left_up', 'right_down', 'right_up', 'space_pressed' ]
      string += "#{key}:"
      for step in inputs[key]
        string += "#{step},"
      string = string.slice(0, -1) if string[string.length - 1] == ',' # remove last ',' if any
      string += '|'
    string = string.slice(0, -1)                                       # remove last '|'

    return LZString.compressToBase64(string)

  @string_to_inputs: (string) ->
    inputs = {}
    string = LZString.decompressFromBase64(string)
    keys   = string.split('|')

    for key in keys
      splitted = key.split(':')
      name     = splitted[0]
      values   = splitted[1].split(',')

      inputs[name] = []
      if values[0] != ''
        for step, i in values
          inputs[name][i] = parseInt(step)

    return inputs

