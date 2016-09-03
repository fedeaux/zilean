angular.module('ZileanApp').factory 'LogEntryService', ($resource, $http) ->
  class LogEntryService
    constructor: (@errorHandler) ->
      @service = $resource('/api/log_entries/:id')

    create: (log_entry, complete) ->
      new @service(log_entry: log_entry.attributes()).$save @onServerResponse(complete), @errorHandler

    delete: (log_entry, complete) ->
      new @service().$delete {id: log_entry.id}, @onServerResponse(complete), @errorHandler

    day: (target_day, complete) ->
      new @service().$get { day: target_day }, @onServerResponse(complete), @errorHandler

    onServerResponse: (complete) ->
      (response) ->
        if complete
          complete response
