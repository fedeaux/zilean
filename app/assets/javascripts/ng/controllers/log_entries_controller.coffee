class LogEntriesController
  @defaultArgs: ->
    @argsFor moment().format DateFormats.db_day

  @argsFor: (target_day_id) ->
    name: 'log_entries'
    day: target_day_id
    component_id: @componentIdFor target_day_id

  @componentIdFor: (target_day_id) ->
    "log-entries-#{target_day_id}"

  constructor: (@scope, @LogEntryService, @LogEntry) ->
    window.log_entries_ctrl = @
    @scope.$on 'Dashboard:DataPublished:Activities:Main', @activitiesLoaded
    @scope.$on 'Dashboard:DataPublished:LogEntries:BlankUpdate', @updateAuxiliarLogEntries

  init: (@target_day_id) ->
    @target_day = moment @target_day_id
    @setAuxiliarDates()
    @service = new @LogEntryService @serverErrorHandler, 'log_entry', 'log_entries'

    @setComponentInfo()
    @scope.$emit 'Dashboard:Register', @component

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

  activitiesLoaded: =>
    if @log_entries_attributes
      @setLogEntries @log_entries_attributes
      @log_entries_attributes = false

    if @log_entries_load_complete
      @log_entries_load_complete()
      @log_entries_load_complete = false

  setLogEntries: (log_entries_attributes) ->
    @dashboard.shared_data.log_entries ?= {}

    for log_entry_attr in log_entries_attributes
      log_entry_attr.activity = @dashboard.shared_data.activities[log_entry_attr.activity.id]
      @dashboard.shared_data.log_entries[log_entry_attr.id] = new @LogEntry log_entry_attr

    @dashboard.publishData
      event_scope: 'LogEntries:BlankUpdate'

  loadLogEntries: (complete) ->
    for log_entry in @referencedLogEntries()
      delete @dashboard.shared_data.log_entries[log_entry.id]

    @log_entries_attributes = false

    @service.day @target_day_id, (data) =>
      if @dashboard.shared_data.activities
        @setLogEntries data.log_entries
        complete() if complete

      else
        @log_entries_attributes = data.log_entries
        @log_entries_load_complete = complete

  updateAuxiliarLogEntries: =>
    @log_entries_as_array = @referencedLogEntries()

    if @table
      @table.refresh @dashboard.shared_data.log_entries

    else
      @table = new LogTable.Table $('#daily-log-table'), @dashboard.shared_data.log_entries, @LogEntry,
        resolution: 10, start_time: @target_day.clone(), cell_generator_class: LogTable.CellsGenerators.Day,
        log_entries_ctrl: @

  referencedLogEntries: ->
    log_entry for id, log_entry of @dashboard.shared_data.log_entries when log_entry.referencesDay(@target_day_id)

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
    if @table.segments.length > 0
      @service.cropMultiple @table.segments, @saveLogEntryCallback

  deleteLogEntry: (log_entry) ->
    @service.delete log_entry, @deleteLogEntryCallback

  hideForm: =>
    @table.clear_selection()

  saveLogEntryCallback: (data) =>
    @loadLogEntries @hideForm

  deleteLogEntryCallback: (data) =>
    delete @dashboard.shared_data.log_entries[data.log_entry.id]
    @updateAuxiliarLogEntries()
    @dashboard.publishData
      event_scope: 'LogEntries:BlankUpdate'

  serverErrorHandler: ->

  loadNew: (target_day_id) ->
    @scope.$emit 'Dashboard:Insert', LogEntriesController.argsFor(target_day_id)

LogEntriesController.$inject = ['$scope', 'LogEntryService', 'LogEntry']
angular.module('ZileanApp').controller 'LogEntriesController', LogEntriesController
AvailableComponents.push LogEntriesController
