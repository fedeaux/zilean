@LogTable ||= {}

class LogTable.Main
  constructor: (table_selector) ->
    @table = $ table_selector

    @table_handler = new LogTable.Table @table
