module LogEntryHelpers
  def select_cells(from: nil, to: nil)
    if from and to
      find_cell(from).trigger :mousedown
      cell_to = find_cell(to)
      cell_to.trigger :mouseover
      cell_to.trigger :mouseup
    end
  end

  def find_cell(time)
    find('.log-entries-table .cell', text: /#{time}/)
  end

  def select_activity(field, activity_id)
    find(field, visible: false).set activity_id
  end
end

RSpec.configure do |config|
  config.include LogEntryHelpers
end
