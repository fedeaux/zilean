class DashboardController
  constructor: (@scope, @compile) ->
    window.dashboard_ctrl = @
    @components = {}
    @components_nodes = {}

    @scope.$on 'Dashboard:Register', @registerComponent
    @scope.$on 'Dashboard:Insert', @insertComponentCallback

    @initializeComponents()

  publishData: (published_data) =>
    @shared_data ?= {}

    for name, data of published_data.data
      @shared_data[name] = data

    @scope.$broadcast "Dashboard:DataPublished:#{published_data.event_scope}"

  insertComponentCallback: (event, params) =>
    @insertComponent params.name, params

  insertComponent: (component_name, parameters = {}) ->
    node = document.createElement 'div'
    attr = document.createAttribute 'dashboard-component'
    parameters['component'] = component_name
    parameters['component_id'] ?= component_name

    attr.value = jQuery.param parameters
    node.setAttributeNode attr
    @components_nodes[parameters['component_id']] = @compile(node)(@scope)
    $('#dashboard-components-wrapper').append @components_nodes[parameters['component_id']]

  removeComponent: (component_id) ->
    @components_nodes[component_id].remove()
    delete @components[component_id]

  registerComponent: (event, component) =>
    @components[component['id']] = component
    component.component.dashboard = @

  toggleComponentVisibility: (component_id) ->
    if @components[component_id]
      @components[component_id].visible = !@components[component_id].visible

  initializeComponents: ->
    for component in AvailableComponents
      args = component.defaultArgs()
      @insertComponent args.name, args

DashboardController.$inject = ['$scope', '$compile']
angular.module('ZileanApp').controller 'DashboardController', DashboardController
