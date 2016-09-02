class LogEntriesController
  @defaultArgs: ->
    @argsFor moment().format DateFormats.db_day

  @argsFor: (target_day_id) ->
    name: 'log_entries'
    day: target_day_id
    component_id: @componentIdFor target_day_id

  @componentIdFor: (target_day_id) ->
    "log-entries-#{target_day_id}"

  constructor: (@$scope, @ResourceService, @LogEntry) ->
    window.log_entries_ctrl = @

  init: (@target_day_id) ->
    @target_day = moment @target_day_id
    @setComponentInfo()
    @$scope.$emit 'Dashboard:Register', @component
    @setAuxiliarDates()

    # @service = new @ResourceService @serverErrorHandler, 'log_entry', 'log_entries'
    # @loadLogEntries()

  setAuxiliarDates: ->
    prev_day = @target_day.clone().subtract 1, 'day'
    next_day = @target_day.clone().add 1, 'day'

    @prev_day =
      date: prev_day
      formatted: prev_day.format(DateFormats.pretty_day)
      db: prev_day.format(DateFormats.db_day)

    @next_day =
      date: next_day
      formatted: next_day.format(DateFormats.pretty_day)
      db: next_day.format(DateFormats.db_day)

  loadLogEntries: (force = false) ->
    @log_entries ?= {}
    @log_entries = {} if force

    @service.index (data) =>
      for log_entry_attr in data['log_entries']
        @log_entries[log_entry_attr.id] = new @LogEntry log_entry_attr

      @updateAuxiliarLogEntries()

  updateAuxiliarLogEntries: ->

  setFormLogEntry: (log_entry) ->
    @form_log_entry = log_entry

    if @form_log_entry.isPersisted()
      @original_form_log_entry = angular.copy log_entry

  setComponentInfo: ->
    @component =
      id: LogEntriesController.componentIdFor(@target_day_id),
      title: @target_day.format(DateFormats.pretty_day),
      visible: true
      size: 'triple'

  saveLogEntry: ->
    if @form_log_entry.isPersisted()
      @service.update @form_log_entry, @saveLogEntryCallback
    else
      @service.create @form_log_entry, @saveLogEntryCallback

    @resetFormLogEntry()

  saveLogEntryCallback: (data) =>
    @loadLogEntries true

  cancelEditLogEntry: ->
    if @original_form_log_entry
      @form_log_entry.setAttributes @original_form_log_entry, true

    @resetFormLogEntry()

  setBlankFormLogEntry: ->
    @setFormLogEntry new @LogEntry

  resetFormLogEntry: ->
    @form_log_entry = null
    @original_form_log_entry = null

  serverErrorHandler: ->

  loadNew: (target_day_id) ->
    @$scope.$emit 'Dashboard:Insert', LogEntriesController.argsFor(target_day_id)

LogEntriesController.$inject = ['$scope', 'ResourceService', 'LogEntry']
angular.module('ZileanApp').controller 'LogEntriesController', LogEntriesController
AvailableComponents.push LogEntriesController
