@LogTable ||= {}

class LogTable.Cell
  constructor: (@index, @row, @column, @date, @cell_generator, @events = {}) ->
    @selected = false

  style: ->
    if @log_entry and @log_entry.activity
      'background-color' : @log_entry.activity.color
    else
      {}

  select: ->
    @selected = true
    @events.on_select this if @events.on_select

  unselect: ->
    @selected = false
    @events.on_deselect this if @events.on_select

  update_neighbourhood: ->
    @neighbourhood =
      top: @cell_generator.cell(@row - 1, @column)
      bottom: @cell_generator.cell(@row + 1, @column)
      right: @cell_generator.cell(@row, @column + 1)
      left: @cell_generator.cell(@row, @column + (-1))

  position: ->
    "#{@row}, #{@column} [#{@index}]"

  isEqual: (other_cell) ->
    @index == other_cell.index

  class: ->
    return '' unless @neighbourhood

    classes = []

    if @selected
      if !@neighbourhood.right or !@neighbourhood.right.selected
        classes.push 'right-selection-border'

      if !@neighbourhood.bottom or !@neighbourhood.bottom.selected
        classes.push 'bottom-selection-border'

      if !@neighbourhood.top
        classes.push 'top-selection-border'

      if !@neighbourhood.left
        classes.push 'left-selection-border'

    else
      if @neighbourhood.bottom and @neighbourhood.bottom.selected
        classes.push 'bottom-selection-border'

      if @neighbourhood.right and @neighbourhood.right.selected
        classes.push 'right-selection-border'

    classes.join ' '
