angular.module('ZileanApp').filter 'elapsed', ($filter) ->
  (minutes) ->
    if !minutes or minutes == 0
      return ''

    days = Math.floor minutes / 24 / 60
    hours = Math.floor ( minutes / 60 ) % 24
    minutes = minutes % 60

    result = []

    if days > 0
      result.push "#{days}d"

    if hours > 0
      result.push "#{hours}h"

    if minutes > 0
      result.push "#{minutes}min"

    result.join ''
