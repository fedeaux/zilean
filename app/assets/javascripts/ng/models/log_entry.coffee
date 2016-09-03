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

      @parseDateFields()

    isPersisted: ->
      !! @id

    parseDateFields: ->
      @started_at = moment @started_at
      @finished_at = moment @finished_at

    defaultAttributes: (update) ->
      attr =
        id: null
        duration: null
        observations: null
        started_at: null
        finished_at: null
        activity: {}

      attr

    attributes: ->
      attr = {}

      for name, default_value of @defaultAttributes(true)
        attr[name] = @[name]

      if @activity
        attr.activity_id = @activity.id

      attr
