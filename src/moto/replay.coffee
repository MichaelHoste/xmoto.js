class Replay

  constructor: (level) ->
    @level   = level
    @success = false
    @steps   = 0
    @inputs  =
      up_down:       []
      up_up:         []
      down_down:     []
      down_up:       []
      left_down:     []
      left_up:       []
      right_down:    []
      right_up:      []
      space_pressed: []

  clone: ->
    new_replay = new Replay(@level)
    new_replay.success = @success
    new_replay.steps   = @steps
    for key in [ 'up_down', 'up_up', 'down_down', 'down_up', 'left_down',
                 'left_up', 'right_down', 'right_up', 'space_pressed' ]
      new_replay.inputs[key] = @inputs[key].slice() # copy array
    return new_replay

  add_step: ->
    @steps = @level.physics.steps
    input  = @level.input

    for key in [ 'up', 'down', 'left', 'right']
      if input[key] && @is_up(key)
        @inputs["#{key}_down"].push(@steps)
      else if !input[key] && @is_down(key)
        @inputs["#{key}_up"].push(@steps)

    if input.space
      @inputs['space_pressed'].push(@steps)

  # TODO dichotomic search
  last: (input) ->
    last_element = null
    input_length = @inputs[input].length

    steps = @level.physics.steps
    for element, i in @inputs[input]
      if element <= steps && (i+1 > input_length-1 || @inputs[input][i+1] > steps)
        last_element = element
        break

    return last_element

  is_up: (key) ->
    @last("#{key}_up") >= @last("#{key}_down")

  is_down: (key) ->
    @last("#{key}_down") >= @last("#{key}_up")

  is_pressed: (key) ->
    @last("#{key}_pressed") == @level.physics.steps

  load: (data) ->
    options = @level.options
    @inputs  = ReplayConversionService.string_to_inputs(data)
    @success = true
    return this

  save: ->
    console.log(ReplayConversionService.inputs_to_string(@inputs))
    console.log(ReplayConversionService.string_to_inputs(ReplayConversionService.inputs_to_string(@inputs)))
    console.log(ReplayConversionService.inputs_to_string(ReplayConversionService.string_to_inputs(ReplayConversionService.inputs_to_string(@inputs))))

    $.post(@level.options.scores_path,
      level:  @level.infos.identifier
      time:   @level.current_time
      steps:  @steps
      replay: ReplayConversionService.inputs_to_string(@inputs)
    )
