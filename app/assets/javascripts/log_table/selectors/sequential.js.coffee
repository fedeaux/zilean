@LogTable ||= {}
@LogTable.Selectors ||= {}

class LogTable.Selectors.Sequential
  constructor: (@table) ->

  set_initial_cell: (@initial_cell) ->
    @targeted_cells = []

  set_ending_cell: (@ending_cell) ->
    cell.unselect() for cell in @targeted_cells

    cells = [@initial_cell, @ending_cell].sort @compare_cells

    first_cell = cells[0]
    last_cell = cells[1]
    current_cell = null

    while true
      if current_cell
        if @table.cell current_cell.row + 1, current_cell.column
          current_cell = @table.cell current_cell.row + 1, current_cell.column
        else
          current_cell = @table.cell 0, current_cell.column + 1

      else
        current_cell = first_cell

      if current_cell and !current_cell.selected
        current_cell.select()
        @targeted_cells.push current_cell

      if !current_cell or current_cell.isEqual last_cell
        break

  compare_cells: (cell_a, cell_b) ->
    if cell_a.column < cell_b.column
      return -1

    if cell_a.column > cell_b.column
      return 1

    if cell_a.row > cell_b.row
      return 1

    else
      return -1
