module LogEntryHelpers
  def select_cells(from: nil, to: nil)
    if from and to
      find_cell(from).trigger :mousedown
      cell_to = find_cell(to)
      cell_to.trigger :mouseover
      cell_to.trigger :mouseup
    end
  end

  def destroy_log_entry(log_entry, day)
    within log_entry_table_selector(day) do
      find(log_entry_list_item_selector(log_entry)).hover
      find(log_entry_list_item_destroy_selector(log_entry)).click
    end
  end

  def log_entry_list_item_destroy_selector(log_entry)
    "#{log_entry_list_item_selector(log_entry)} .destroy-log-entry-button"
  end

  def log_entry_list_item_selector(log_entry)
    ".log-entry-list-item-#{log_entry.id}"
  end

  def log_entry_table_selector(day)
    "#log-entries-#{day.strftime('%Y-%m-%d')}-component"
  end

  def find_cell(time)
    find('.log-entries-table .cell', text: /#{time}/)
  end

  def select_activity(field_selector, activity_name, _log_entry_table_selector)
    page.execute_script("$('#{_log_entry_table_selector} #{field_selector}').dropdown('set selected', '#{activity_name}')")
  end

  def create_log_entry(from, to, activity, day = Time.now)
    _log_entry_table_selector = log_entry_table_selector day

    within _log_entry_table_selector do
      select_cells from: from, to: to
      select_activity '.log_entry_activity_hidden_selector', activity.name, _log_entry_table_selector
      find('.log-entries-selection-save').click
      expect(page).to have_css '.log-entry-list .log-entry-wrapper'
    end
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
