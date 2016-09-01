class DashboardController
  constructor: (@scope) ->
    window.dashboard_ctrl = @
    @components = {}
    @scope.$on 'Dashboard:Register', @registerComponent

  registerComponent: (event, component) =>
    @components[component['id']] = component

  toggleComponentVisibility: (component_id) ->
    if @components[component_id]
      @components[component_id].visible = !@components[component_id].visible

DashboardController.$inject = ['$scope']
angular.module('ZileanApp').controller 'DashboardController', DashboardController
