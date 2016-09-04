angular.module('ZileanApp').directive('activityPicker', ($timeout) ->
  return {
    restrict: 'A'

    templateUrl: (element, args) ->
      url_args = jQuery.param JSON.parse args.activityPicker
      "templates/activities/picker?#{url_args}"

    link: (scope, element, attr) ->
      select = $ 'select', element
      model = $('select', element).attr 'ng-model'

      scope.$watch model, ->
        select.dropdown(
          fullTextSearch: true
        )
  }
)
