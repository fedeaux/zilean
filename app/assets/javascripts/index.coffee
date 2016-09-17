@DateFormats =
  db_day: 'YYYY-MM-DD'
  pretty_day: 'ddd, MMM Do'
  hour_and_minute: 'HH:mm'

@AvailableComponents = []

init = ->
  $('.ui.dropdown').dropdown(
    action: 'hide'
    on: 'hover'
  )

$(document).on 'page:load', init
$(document).ready init
