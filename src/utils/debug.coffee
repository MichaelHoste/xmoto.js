# Special debug mode to change constants visually

bind_debug_button = ->
  $('#debug .debug-button').on('click', ->
    window.location = '?level=' + $("#levels option:selected").text() + '&debug=false'
    false
  )

bind_delete_params_buttons = ->
  $("#debug span.delete").on('click', ->
    $(this).closest('.template').remove()
    $('#debug form').submit()
  )

override_constants_by_url_params = (params) ->
  for key, value of params
    array_keys = key.split('.')
    array = Constants
    for array_key, i in array_keys
      if i == array_keys.length - 1
        if value == ''
          delete params[key]
        else
          if value == 'true' or value == 'false'
            array[array_key] = value == 'true'
          else if array_key != 'level'
            array[array_key] = parseFloat(value)
      else
        array = array[array_key]

display_constants = ->
  # display all the keys with direct link
  html = '<ul>'
  for key in Object.keys(Constants)
    value = Constants[key]
    if typeof value != 'object'
      html += "<li><a href=\"#{document.URL}&#{key}=#{value}\">#{key}</a> (#{value})</li>"
    else
      html += "<li>#{key}<ul>"
      for sub_key, sub_value of Constants[key]
        if typeof sub_value != 'object'
          html += "<li><a href=\"#{document.URL}&#{key}.#{sub_key}=#{sub_value}\">#{sub_key}</a> (#{sub_value})</li>"
      html += "</ul></li>"

  html += '</ul>'
  $('#debug .variables').html(html)

  # Hide ul without li (object with only other objects as value)
  $("ul > li > ul:not(:has(> li))").parent().hide()

create_form_with_url_params = (params) ->
  for key, value of params
    new_input = $('form.debug .template:first').clone().insertBefore('form.debug input[type=submit]')
    new_input.find('label').attr('for', key).text(key)
    new_input.find('input').attr('name', key).attr('id', key).val(value)
    new_input.show()
    $('form.debug .template:first').hide()

$ ->
  params = $.url().param()

  if $('#debug').length and Object.keys(params).length > 1 # level param is accepted with debug mode off
    $('.debug').show()
    $('.debug-button').hide()

    override_constants_by_url_params(params)
    create_form_with_url_params(params)
    display_constants()

  bind_debug_button()
  bind_delete_params_buttons()
