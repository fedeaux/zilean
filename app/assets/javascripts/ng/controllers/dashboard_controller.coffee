class DashboardController
  constructor: (@scope) ->
    window.dashboard_ctrl = @
    @components = {}
    @scope.$on 'Dashboard:Register', @registerComponent

  registerComponent: (event, component) =>
    @components[component['id']] = component

DashboardController.$inject = ['$scope']
angular.module('ZileanApp').controller 'DashboardController', DashboardController
