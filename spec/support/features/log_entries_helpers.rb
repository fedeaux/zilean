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

  def select_activity(field_selector, activity_name)
    page.execute_script("$('#{field_selector}').dropdown('set selected', '#{activity_name}')")
  end

  def create_log_entry(from, to, activity)
    select_cells from: from, to: to

    within '#table-selection' do
      select_activity '#log_entry_activity_id', activity.name
      find('.log-entries-selection-save').click
    end

    expect(page).to have_css '.log-entry-list .log-entry-wrapper'
  end

  def to_local_time(time)
    time -= page.evaluate_script('new Date().getTimezoneOffset()').to_i.minutes
  end

  def to_table_time(time)
    to_local_time(time).strftime('%H:%M')
  end
end

RSpec.configure do |config|
  config.include LogEntryHelpers
end
