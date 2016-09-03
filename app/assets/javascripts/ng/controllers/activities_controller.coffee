class ActivitiesController
  @defaultArgs: ->
    name: 'activities'

  constructor: (@$scope, @ResourceService, @Activity) ->
    window.activities_ctrl = @
    @$scope.$emit 'Dashboard:Register', @component
    @service = new @ResourceService @serverErrorHandler, 'activity', 'activities'
    @loadActivities()

  loadActivities: (force = false) ->
    @activities ?= {}
    @activities = {} if force

    @service.index (data) =>
      for activity_attr in data['activities']
        @activities[activity_attr.id] = new @Activity activity_attr

      @updateAuxiliarActivities()

  updateAuxiliarActivities: ->
    @displayable_activities = (activity for id, activity of @activities)
    @all_activities = [].concat.apply([], (activity.withChildren() for id, activity of @activities))

    @activities_as_options = angular.copy @all_activities
    @activities_as_options.unshift { breadcrumbs_path_names: '[none]', id: null }

  setFormActivity: (activity) ->
    @form_activity = activity

    if @form_activity.isPersisted()
      @original_form_activity = angular.copy activity

  component:
    id: 'activities',
    title: 'Activities',
    visible: true

  saveActivity: ->
    if @form_activity.isPersisted()
      @service.update @form_activity, @saveActivityCallback
    else
      @service.create @form_activity, @saveActivityCallback

    @resetFormActivity()

  saveActivityCallback: (data) =>
    @loadActivities true

  cancelEditActivity: ->
    if @original_form_activity
      @form_activity.setAttributes @original_form_activity, true

    @resetFormActivity()

  setBlankFormActivity: ->
    @setFormActivity new @Activity

  resetFormActivity: ->
    @form_activity = null
    @original_form_activity = null

  serverErrorHandler: ->

ActivitiesController.$inject = ['$scope', 'ResourceService', 'Activity']
angular.module('ZileanApp').controller 'ActivitiesController', ActivitiesController
AvailableComponents.push ActivitiesController
