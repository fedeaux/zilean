class LogEntriesController
  constructor: (@$scope, @ResourceService, @LogEntry) ->
    window.log_entries_ctrl = @
    @$scope.$emit 'Dashboard:Register', @component
    @service = new @ResourceService @serverErrorHandler, 'log_entry', 'log_entries'
    @loadLogEntries()

  loadLogEntries: (force = false) ->
    @log_entries ?= {}
    @log_entries = {} if force

    @service.index (data) =>
      for log_entry_attr in data['log_entries']
        @log_entries[log_entry_attr.id] = new @LogEntry log_entry_attr

      @updateAuxiliarLogEntries()

  updateAuxiliarLogEntries: ->
    # @displayable_log_entries = (log_entry for id, log_entry of @log_entries)
    # @all_log_entries = [].concat.apply([], (log_entry.withChildren() for id, log_entry of @log_entries))

    # @log_entries_as_options = angular.copy @all_log_entries
    # @log_entries_as_options.unshift { breadcrumbs_path_names: '[none]', id: null }

  setFormLogEntry: (log_entry) ->
    @form_log_entry = log_entry

    if @form_log_entry.isPersisted()
      @original_form_log_entry = angular.copy log_entry

  component:
    id: 'log_entries',
    title: 'Log',
    visible: true

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

LogEntriesController.$inject = ['$scope', 'ResourceService', 'LogEntry']
angular.module('ZileanApp').controller 'LogEntriesController', LogEntriesController
