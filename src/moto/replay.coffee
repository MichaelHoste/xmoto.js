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
    @key_steps = {}

  clone: ->
    new_replay = new Replay(@level)
    new_replay.success = @success
    new_replay.steps   = @steps

    # Copy inputs
    for key in [ 'up_down', 'up_up', 'down_down', 'down_up', 'left_down',
                 'left_up', 'right_down', 'right_up', 'space_pressed' ]
      new_replay.inputs[key] = @inputs[key].slice() # copy array

    # Copy key-steps
    for key, value of @key_steps
      new_replay.key_steps[key] = {}
      for part in ['body', 'left_wheel', 'right_wheel', 'left_axle', 'right_axle',
                   'torso', 'upper_leg', 'lower_leg', 'upper_arm', 'lower_arm']
        new_replay.key_steps[key][part] =
          position:
            x:              value[part].position.x
            y:              value[part].position.y
          angle:            value[part].angle
          linear_velocity:
            x:              value[part].linear_velocity.x
            y:              value[part].linear_velocity.y
          angular_velocity: value[part].angular_velocity

    return new_replay

  add_step: ->
    @steps = @level.physics.steps
    @add_inputs()
    @add_key_steps()

  add_inputs: ->
    input  = @level.input

    for key in [ 'up', 'down', 'left', 'right']
      if input[key] && @is_up(key)
        @inputs["#{key}_down"].push(@steps)
      else if !input[key] && @is_down(key)
        @inputs["#{key}_up"].push(@steps)

    if input.space
      @inputs['space_pressed'].push(@steps)

  add_key_steps: ->
    moto   = @level.moto
    rider  = moto.rider

    if @steps % Constants.replay_key_step == 0
      key_step = @key_steps[@steps.toString()] = {}

      for part in ['body', 'left_wheel', 'right_wheel', 'left_axle', 'right_axle']
        key_step[part] = physics_values(moto[part])

      for part in ['torso', 'upper_leg', 'lower_leg', 'upper_arm', 'lower_arm']
        key_step[part] = physics_values(rider[part])

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
    @inputs     = ReplayConversionService.string_to_inputs(data.split("\n")[0])
    @key_steps = ReplayConversionService.string_to_key_steps(data.split("\n")[1])
    @success    = true
    return this

  save: ->
    inputs_string     = ReplayConversionService.inputs_to_string(@inputs)
    key_steps_string = ReplayConversionService.key_steps_to_string(@key_steps)
    replay_string     = inputs_string + "\n" + key_steps_string

    console.log(replay_string)

    $.post(@level.options.scores_path,
      level:  @level.infos.identifier
      time:   @level.current_time
      steps:  @steps
      replay: replay_string
    )

physics_values = (object) ->
  position:
    x:              object.GetPosition().x
    y:              object.GetPosition().y
  angle:            object.GetAngle()
  linear_velocity:
    x:              object.GetLinearVelocity().x
    y:              object.GetLinearVelocity().y
  angular_velocity: object.GetAngularVelocity()
