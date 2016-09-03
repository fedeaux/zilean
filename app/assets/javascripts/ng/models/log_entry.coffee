angular.module('ZileanApp').factory 'LogEntry', ($resource) ->
  class LogEntry
    constructor: (attributes = {}) ->
      @setAttributes attributes

    setAttributes: (attributes, update = false) ->
      for name, default_value of @defaultAttributes(update)
        if attributes.hasOwnProperty(name) and attributes[name] != null
          @[name] = attributes[name]
        else
          @[name] = default_value

    isPersisted: ->
      !! @id

    defaultAttributes: (update) ->
      attr =
        id: null
        duration: null
        activity: {}

      attr

    attributes: ->
      attr = {}

      for name, default_value of @defaultAttributes(true)
        attr[name] = @[name]

      if @parent
        attr.parent_id = @parent.id

      attr
