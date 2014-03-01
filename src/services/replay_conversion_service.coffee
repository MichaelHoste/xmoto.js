# Convert replay from object to minified string to be send to the server
# And vice versa

class ReplayConversionService

  @object_to_string: (replay) ->
    string = ''

    for frame in replay.frames
      mirror = if frame.mirror then '1' else '0'
      string += "#{frame.time}|#{mirror}"

      for element in [ 'left_wheel', 'right_wheel', 'body', 'torso',
                       'upper_leg', 'lower_leg', 'upper_arm', 'lower_arm' ]
        string += frame[element].position.x.toFixed(2) + ''
        string += frame[element].position.y.toFixed(2) + ''
        string += frame[element].angle.toFixed(2) + ''

    console.log(string.length / replay.frames.length)
    console.log(LZString.compress(string).length / replay.frames.length)

    console.log(string.length)
    console.log(LZString.compress(string).length)

    return string

  @string_to_object: (replay) ->
    ;
