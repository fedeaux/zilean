@LogTable ||= {}
@LogTable.Selectors ||= {}

class LogTable.Selectors.Square
  constructor: (@table) ->

  set_initial_cell: (@initial_cell) ->
    @targeted_cells = []

  set_ending_cell: (@ending_cell) ->
    cell.unselect() for cell in @targeted_cells

    for row in [(@initial_cell.row)..(@ending_cell.row)]
      for column in [(@initial_cell.column)..(@ending_cell.column)]
        cell = @table.cell(row, column)

        if cell and !cell.selected
          cell.select()
          @targeted_cells.push cell
