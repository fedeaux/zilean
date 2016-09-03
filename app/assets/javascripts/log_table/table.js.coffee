@LogTable ||= {}

class LogTable.Table
  constructor: (@table, @log_entries, @LogEntry, @options) ->
    @initialize_cells()
    @sequential_selector = new LogTable.Selectors.Sequential @

    @assign_log_entries_to_cells()
    @assign_events()

  initialize_cells: ->
    @cell_generator = new @options.cell_generator_class @, @options.resolution,
      on_select: @on_cell_select
      on_deselect: @on_cell_deselect

    @cells = @cell_generator.generate @options.start_time
    @segments = []

  assign_log_entries_to_cells: ->
    cell.log_entry = null for cell in @cells

    for log_entry_id, log_entry of @log_entries
      cells = @cells_between log_entry.started_at, log_entry.finished_at

      for cell in cells
        cell.log_entry = log_entry

  cells_between: (started_at, finished_at) ->
    @cells.filter (cell) ->
      (cell.date >= started_at) and (cell.date < finished_at)

  assign_events: ->
    $('body').mouseup @handle_mouseup

    @header = $ '.header', @table
    @header.click @clear_selection

  cell: (row_or_cell_element, column = null) ->
    if column != null
      row = row_or_cell_element

    else
      row = row_or_cell_element.attr 'data-row'
      column = row_or_cell_element.attr 'data-column'

    @cell_generator.cell row, column

  on_cell_select: (cell) =>
    @update_time_segments()

  on_cell_deselect: (cell) =>
    @update_time_segments()

  current_selection_sorted_by_date: ->
    @current_selection().sort (cell_a, cell_b) ->
      if (cell_a.date < cell_b.date)
        return -1
      if (cell_a.date > cell_b.date)
        return 1

      return 0

  update_time_segments: ->
    @segments = []

    current_segment = null

    for cell in @current_selection_sorted_by_date()
      finish_date = cell.date.clone()
      finish_date.add @options.resolution, 'minutes'

      unless current_segment and current_segment.finished_at.isSame cell.date
        current_segment = new @LogEntry { started_at: cell.date, finished_at: finish_date }

        @segments.push current_segment

      else
        current_segment.finished_at = finish_date

  current_selection: ->
    cell for cell in @cells when cell.selected

  clear_selection: =>
    cell.unselect() for cell in @current_selection()

  number_of_selected_cells: ->
    @current_selection().length

  time_of_selected_cells: ->
    @number_of_selected_cells() * @options.resolution

  selected_time: ->
    @current_selection().length * @options.resolution

  handle_click: (e) =>
    e.preventDefault()
    e.stopPropagation()
    false

  handle_mousedown: ($event, cell) =>
    if $event.altKey
      @selector = 'simple'
    else
      @selector = @sequential_selector
      @selector.set_initial_cell cell

    @clear_selection() unless $event.shiftKey
    cell.select()

  handle_mouseenter: ($event, cell) =>
    if @selector == 'simple'
      cell.select()

    else if @selector
      @selector.set_ending_cell cell

    else
      @focused_log_entry = cell.log_entry

  handle_mouseleave: ($event, cell) ->
    @focused_log_entry = null

  handle_mouseup: (e) =>
    @selector = false
