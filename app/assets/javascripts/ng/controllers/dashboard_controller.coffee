class DashboardController
  constructor: (@scope, @compile) ->
    window.dashboard_ctrl = @
    @components = {}

    @scope.$on 'Dashboard:Register', @registerComponent
    @scope.$on 'Dashboard:Insert', @insertComponentCallback

    @initializeComponents()

  insertComponentCallback: (event, params) =>
    @insertComponent params.name, params

  insertComponent: (component_name, parameters = {}) ->
    node = document.createElement 'div'
    attr = document.createAttribute 'dashboard-component'
    parameters['component'] = component_name
    parameters['component_id'] ?= component_name

    attr.value = jQuery.param parameters
    node.setAttributeNode attr
    $('#dashboard-components-wrapper').append @compile(node)(@scope)

  registerComponent: (event, component) =>
    @components[component['id']] = component

  toggleComponentVisibility: (component_id) ->
    if @components[component_id]
      @components[component_id].visible = !@components[component_id].visible

  initializeComponents: ->
    for component in AvailableComponents
      args = component.defaultArgs()
      @insertComponent args.name, args

DashboardController.$inject = ['$scope', '$compile']
angular.module('ZileanApp').controller 'DashboardController', DashboardController
