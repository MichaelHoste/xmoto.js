# Convert replay from object to minified string to be send to the server
# And vice versa
class ReplayConversionService

  # String is like : "keyA:199,240,569|keyB:29,40,55..."
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

  # String is like : "60@step1=step2=step3=..." where 60 is the key-step interval of the replay
  # step1 is like : "part1_positions|part2_positions|...|part10_positions"
  # part1_positions is like : "11.1234,22.1234,33.1234,44.1234,55.1234,66.1234" (each position and angle values)
  @key_steps_to_string: (key_steps) ->
    string = "#{Constants.replay_key_step}@"
    for step, key_step of key_steps
      for key in ['body', 'left_wheel', 'right_wheel', 'left_axle', 'right_axle',
                  'torso', 'upper_leg', 'lower_leg', 'upper_arm', 'lower_arm']
        a = key_step[key].position.x       .toFixed(Constants.replay_key_step_precision)
        b = key_step[key].position.y       .toFixed(Constants.replay_key_step_precision)
        c = key_step[key].angle            .toFixed(Constants.replay_key_step_precision)
        d = key_step[key].linear_velocity.x.toFixed(Constants.replay_key_step_precision)
        e = key_step[key].linear_velocity.y.toFixed(Constants.replay_key_step_precision)
        f = key_step[key].angular_velocity .toFixed(Constants.replay_key_step_precision)
        string += "#{a},#{b},#{c},#{d},#{e},#{f}|"
      string = string.slice(0, -1) # remove last '|'
      string += '='
    string = string.slice(0, -1) if string[string.length-1] == '=' # remove last '='

    return LZString.compressToBase64(string)

  @string_to_key_steps: (string) ->
    key_steps        = {}
    string           = LZString.decompressFromBase64(string)
    key_steps_string = string.split('@')[1]

    step_interval     = parseInt(string.split('@')[0])
    current_interval  = step_interval

    # If no "=", then there are no key-steps and we return empty object
    return key_steps if key_steps_string.indexOf("=") == -1

    for key_step_string in key_steps_string.split('=')
      key_step = {}
      part_string = key_step_string.split('|')
      for element, i in ['body', 'left_wheel', 'right_wheel', 'left_axle', 'right_axle',
                         'torso', 'upper_leg', 'lower_leg', 'upper_arm', 'lower_arm']
        value_string = part_string[i].split(',')
        key_step[element] =
          position:
            x:              parseFloat(value_string[0])
            y:              parseFloat(value_string[1])
          angle:            parseFloat(value_string[2])
          linear_velocity:
            x:              parseFloat(value_string[3])
            y:              parseFloat(value_string[4])
          angular_velocity: parseFloat(value_string[5])

      key_steps[current_interval] = key_step
      current_interval += step_interval

    return key_steps
