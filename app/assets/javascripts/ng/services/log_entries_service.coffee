angular.module('ZileanApp').factory 'LogEntryService', ($resource, $http) ->
  class LogEntryService
    constructor: (@errorHandler) ->
      @service = $resource('/api/log_entries/:id')

    createMultiple: (log_entries, complete) ->
      log_entries_attributes = (log_entry.attributes() for log_entry in log_entries)
      new @service(log_entries: log_entries_attributes).$save @onServerResponse(complete), @errorHandler

    delete: (log_entry, complete) ->
      new @service().$delete {id: log_entry.id}, @onServerResponse(complete), @errorHandler

    day: (target_day, complete) ->
      new @service().$get { day: target_day }, @onServerResponse(complete), @errorHandler

    onServerResponse: (complete) ->
      (response) ->
        if complete
          complete response
