angular.module('ZileanApp').controller 'DashboardController', ($scope, $route, $routeParams, $location) ->
  window.dashboard_scope = $scope
  $scope.modules = {}

  $scope.$on 'Dashboard:Register', (event, module) ->
    $scope.modules[module['id']] = module

  $scope.isVisible = (module_id) ->
    $scope.modules[module_id].visible

  serverErrorHandler = ->
