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

  @milestones_to_string: (milestones) ->
    string = '30@'
    for step, milestone of milestones
      for key in ['body', 'left_wheel', 'right_wheel', 'left_axle', 'right_axle',
                  'torso', 'upper_leg', 'lower_leg', 'upper_arm', 'lower_arm']
        a = milestone[key].position.x
        b = milestone[key].position.y
        c = milestone[key].angle
        d = milestone[key].linear_velocity.x
        e = milestone[key].linear_velocity.y
        f = milestone[key].angular_velocity
        string += "#{a},#{b},#{c},#{d},#{e},#{f}|"
      string = string.slice(0, -1) # remove last '|'
      string += '='
    string = string.slice(0, -1) # remove last '='

    return LZString.compressToBase64(string)

  @string_to_milestones: (string) ->
    milestones        = {}
    string            = LZString.decompressFromBase64(string)
    milestones_string = string.split('@')[1]

    step_interval     = parseInt(string.split('@')[0])
    current_interval  = step_interval

    for milestone_string in milestones_string.split('=')
      milestone = {}
      part_string = milestone_string.split('|')
      for element, i in ['body', 'left_wheel', 'right_wheel', 'left_axle', 'right_axle',
                         'torso', 'upper_leg', 'lower_leg', 'upper_arm', 'lower_arm']
        value_string = part_string[i].split(',')
        milestone[element] =
          position:
            x:              parseFloat(value_string[0])
            y:              parseFloat(value_string[1])
          angle:            parseFloat(value_string[2])
          linear_velocity:
            x:              parseFloat(value_string[3])
            y:              parseFloat(value_string[4])
          angular_velocity: parseFloat(value_string[5])

      milestones[current_interval] = milestone
      current_interval += step_interval

    return milestones
