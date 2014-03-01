# Convert replay from object to minified string to be send to the server
# And vice versa

class ReplayConversionService

  @object_to_string: (replay_object) ->
    string = ''

    for frame in replay_object.frames
      string += if frame.mirror then '1' else '0'
      for element in [ 'left_wheel', 'right_wheel', 'body', 'torso',
                       'upper_leg', 'lower_leg', 'upper_arm', 'lower_arm' ]
        string += frame[element].position.x.toFixed(2) + ''
        string += frame[element].position.y.toFixed(2) + ''
        string += frame[element].angle.toFixed(2) + ''
      string += '|'
    string = string.slice(0, -1) # remove last '|'

    console.log(string.length)
    console.log(LZString.compress(string).length)

    console.log(string)

    return string

  @string_to_object: (level, replay_string) ->
    object = new Replay(level)

    frames_string = replay_string.split('|')

    for frame_string in frames_string
      frame = {}
      frame['mirror'] = frame_string[0] == '1'
      position = 1
      for element in [ 'left_wheel', 'right_wheel', 'body', 'torso',
                       'upper_leg', 'lower_leg', 'upper_arm', 'lower_arm' ]
        frame[element] = {}
        frame[element]['position'] = {}
        for axe in [ 'x', 'y' ]
          number = @next_number(frame_string, position)
          frame[element]['position'][axe] = parseFloat(number)
          position = position + number.length

        number = @next_number(frame_string, position)
        frame[element]['angle'] = parseFloat(number)
        position = position + number.length
      object.frames.push(frame)

    return object

  # Take next number in a string from position (assuming numbers always have 2 digits)
  # ex: 1.4567.22578.22
  #     next number from position 0 is "1.45"
  #     next number from position 4 is "67.22"
  #     next number from position 8 is "578.22"
  @next_number: (string, position) ->
    number = string.substring(position, position + 12) # max 8 decimals + a sign before the coma, sure enough !
    number_parts = number.split('.')
    return number_parts[0] + '.' + number_parts[1].substring(0, 2)
