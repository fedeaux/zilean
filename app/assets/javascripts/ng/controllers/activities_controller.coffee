class ActivitiesController
  constructor: (@$scope, @$route, @$routeParams, @$location, @ResourceService, @Activity) ->
    window.activities_ctrl = @
    @$scope.$emit 'Dashboard:Register', @module
    @service = new @ResourceService @serverErrorHandler, 'activity', 'activities'
    @loadActivities()

  loadActivities: ->
    @activities ?= {}

    @service.index (data) =>
      for activity_attr in data['activities']
        @activities[activity_attr.id] = new @Activity activity_attr

      @updateDisplayableActivities()

  updateDisplayableActivities: ->
    @displayable_activities = (activity for id, activity of @activities)

  module:
    id: 'activities',
    name: 'Activities',
    visible: true

  serverErrorHandler: ->

ActivitiesController.$inject = ['$scope', '$route', '$routeParams', '$location', 'ResourceService', 'Activity']
angular.module('ZileanApp').controller 'ActivitiesController', ActivitiesController
