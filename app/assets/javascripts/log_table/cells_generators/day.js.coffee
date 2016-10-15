@LogTable ||= {}
@LogTable.CellsGenerators ?= {}

class LogTable.CellsGenerators.Day
  constructor: (@table, @resolution, @cell_events) ->
    @number_of_columns = 6
    @number_of_cells = Math.floor 24 * 60 / @resolution
    @number_of_rows = Math.floor @number_of_cells / @number_of_columns

  generate: (current_time) ->
    @cells = []
    current_cell = 0
    base_time = angular.copy current_time

    while current_cell < @number_of_cells
      row = Math.floor current_cell / @number_of_columns
      column = current_cell % @number_of_columns

      if column == 0 and row > 0
        base_time.add @resolution, 'minutes'
        current_time = angular.copy base_time

      @cells.push(new LogTable.Cell current_cell, row, column, angular.copy(current_time), @, @cell_events)

      current_cell += 1
      current_time.add 4, 'hours'

    cell.update_neighbourhood() for cell in @cells
    @cells

  index: (row, column) ->
    return null if row < 0 or row >= @number_of_rows
    return null if column < 0 or column >= @number_of_columns

    row * @number_of_columns + column

  cell: (row, column) ->
    index = @index row, column

    if index?
      @cells[index] or null
