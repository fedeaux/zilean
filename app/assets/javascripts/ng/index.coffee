ZileanApp = angular.module('ZileanApp', ['ngResource', 'ngRoute'])

init = ->
  angular.bootstrap($('body'), ['ZileanApp'])

$(document).on 'page:load', init
$(document).ready init
