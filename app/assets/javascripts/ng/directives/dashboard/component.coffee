angular.module('ZileanApp').directive('dashboardComponent', ->
  return {
    templateUrl: (element, args) ->
      "templates/dashboard/components/main?#{args.dashboardComponent}"
  }
)
