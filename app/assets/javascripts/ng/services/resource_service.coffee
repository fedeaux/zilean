angular.module('ZileanApp').factory 'ResourceService', ($resource, $http) ->
  class ResourceService
    constructor: (@errorHandler, @singular_name, @plural_name) ->
      @service = $resource("/api/#{@plural_name}/:id", {}, {
       'update': { method: 'PUT'}
      })

    create: (model, complete) ->
      new @service("#{@singular_name}": model.attributes()).$save @onServerResponse(complete), @errorHandler

    update: (model, complete) ->
      new @service("#{@singular_name}": model.attributes()).$update { id: model.id }, @onServerResponse(complete), @errorHandler

    delete: (model, complete) ->
      new @service().$delete {id: model.id}, @onServerResponse(complete), @errorHandler

    index: (complete) ->
      new @service().$get (data) ->
        complete data if complete

    get: (model_id, complete) ->
      new @service().$get id: model_id, @onServerResponse complete

    onServerResponse: (complete) ->
      (response) ->
        if complete
          complete response
