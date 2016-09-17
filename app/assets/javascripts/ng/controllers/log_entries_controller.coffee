class LogEntriesController
  @defaultArgs: ->
    @argsFor moment().format DateFormats.db_day

  @argsFor: (target_day_id) ->
    name: 'log_entries'
    day: target_day_id
    component_id: @componentIdFor target_day_id

  @componentIdFor: (target_day_id) ->
    "log-entries-#{target_day_id}"

  constructor: (@$scope, @LogEntryService, @LogEntry) ->
    window.log_entries_ctrl = @

  init: (@target_day_id) ->
    @target_day = moment @target_day_id
    @setAuxiliarDates()
    @service = new @LogEntryService @serverErrorHandler, 'log_entry', 'log_entries'

    @setComponentInfo()
    @$scope.$emit 'Dashboard:Register', @component

    @loadLogEntries()

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

  loadLogEntries: (force = false, complete) ->
    @log_entries ?= {}
    @log_entries = {} if force

    @service.day @target_day_id, (data) =>
      for log_entry_attr in data['log_entries']
        @log_entries[log_entry_attr.id] = new @LogEntry log_entry_attr

      @updateAuxiliarLogEntries()

      if @table
        @table.refresh @log_entries

      else
        @table = new LogTable.Table $('#daily-log-table'), @log_entries, @LogEntry,
          resolution: 10, start_time: @target_day.clone(), cell_generator_class: LogTable.CellsGenerators.Day,
          log_entries_ctrl: @

      complete() if complete

  updateAuxiliarLogEntries: ->
    @log_entries_as_array = (log_entry for id, log_entry of @log_entries)

  setComponentInfo: ->
    @component =
      id: LogEntriesController.componentIdFor(@target_day_id),
      title: @target_day.format(DateFormats.pretty_day),
      visible: true
      removable: moment().format(DateFormats.db_day) != @target_day_id
      size: 'double'
      component: @

  saveLogEntries: ->
    @service.createMultiple @table.segments, @saveLogEntryCallback

  cropSelection: ->
    @service.cropMultiple @table.segments, @saveLogEntryCallback

  deleteLogEntry: (log_entry) ->
    @service.delete log_entry, @deleteLogEntryCallback

  saveLogEntryCallback: (data) =>
    @loadLogEntries true, @hideForm

  hideForm: =>
    @table.clear_selection()

  deleteLogEntryCallback: (data) =>
    delete @log_entries[data.log_entry.id]
    @updateAuxiliarLogEntries()
    @table.assign_log_entries_to_cells()

  serverErrorHandler: ->

  loadNew: (target_day_id) ->
    @$scope.$emit 'Dashboard:Insert', LogEntriesController.argsFor(target_day_id)

LogEntriesController.$inject = ['$scope', 'LogEntryService', 'LogEntry']
angular.module('ZileanApp').controller 'LogEntriesController', LogEntriesController
AvailableComponents.push LogEntriesController
