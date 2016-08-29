angular.module('ZileanApp').factory 'Activity', ($resource) ->
  class Activity
    constructor: (attributes = {}) ->
      @setAttributes attributes

    setAttributes: (attributes, update = false) ->
      for name, default_value of @defaultAttributes(update)
        if attributes.hasOwnProperty(name) and attributes[name] != null
          @[name] = attributes[name]
        else
          @[name] = default_value

      @createChildren() unless update

    isPersisted: ->
      !! @id

    defaultAttributes: (update) ->
      attr =
        id: null
        name: null
        slug: null
        color: null
        parent_id: null
        breadcrumbs_path_names: ''

      unless update
        attr.children = []

      attr

    attributes: ->
      attr = {}

      for name, default_value of @defaultAttributes(true)
        attr[name] = @[name]

      attr

    createChildren: ->
      if angular.isArray @children
        children = {}
        for activity in @children
          children[activity.id] = new Activity activity

        @children = children

    withChildren: ->
      all = [@].concat (child.withChildren() for id, child of @children)
      [].concat.apply [], all

    # saveMessage: (task_message) ->
    #   @task_messages[task_message.id] = task_message

    # removeTaskMessage: (task_message) ->
    #   delete @task_messages[task_message.id]

    # parseDateFields: ->
    #   for name in @dateAttributes()
    #     if @[name]
    #       @[name] = moment(@[name]).utc()
    #       @["formatted_#{name}"] = @[name].format Form.moment_datetime_format
