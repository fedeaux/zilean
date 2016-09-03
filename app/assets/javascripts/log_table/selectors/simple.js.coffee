@LogTable ||= {}

class LogTable.Selection
  constructor: (wrapper_selector) ->
    @wrapper = $ wrapper_selector
