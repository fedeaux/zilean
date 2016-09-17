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
      @addAuxiliarFields()

    isPersisted: ->
      !! @id

    parseDateFields: ->
      @started_at = moment @started_at
      @finished_at = moment @finished_at

    defaultAttributes: (update) ->
      attr =
        id: null
        observations: null
        started_at: null
        finished_at: null

      unless update
        attr.activity = {}
        attr.duration = null

      attr

    addAuxiliarFields: ->
      first_day = @started_at.format DateFormats.db_day
      last_day = @finished_at.format DateFormats.db_day

      @days = [first_day]

      if last_day != first_day and @finished_at.format(DateFormats.hour_and_minute) != '00:00'
        @days.push last_day

    referencesDay: (day) ->
      @days.indexOf(day) > -1

    attributes: ->
      attr = {}

      for name, default_value of @defaultAttributes(true)
        attr[name] = @[name]

      if @activity
        attr.activity_id = @activity.id

      attr
