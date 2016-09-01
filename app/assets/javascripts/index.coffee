init = ->
  $('.ui.dropdown').dropdown(
    action: 'hide'
    on: 'hover'
  )

$(document).on 'page:load', init
$(document).ready init
