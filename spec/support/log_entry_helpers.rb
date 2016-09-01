module LogEntryHelpers
  def expect_log_entry_merge(previous_log_entry_attributes, new_log_entry_attributes)
    smallest_started_at = [previous_log_entry_attributes[:started_at], new_log_entry_attributes[:started_at]].min
    greatest_finished_at = [previous_log_entry_attributes[:finished_at], new_log_entry_attributes[:finished_at]].max

    previous_log_entry = LogEntry.create(previous_log_entry_attributes).first

    log_entry_count_before_new = LogEntry.count

    new_log_entry = LogEntry.create(new_log_entry_attributes).first

    previous_log_entry.reload

    expect(LogEntry.count).to eq log_entry_count_before_new
    expect(new_log_entry.id).to eq previous_log_entry.id
    expect(previous_log_entry.started_at).to eq smallest_started_at
    expect(previous_log_entry.finished_at).to eq greatest_finished_at
  end

  def expect_log_entry_trim(previous_log_entry_attributes, new_log_entry_attributes)
    previous_log_entry = LogEntry.create(previous_log_entry_attributes).first
    log_entry_count_before_new = LogEntry.count
    affected_log_entries = LogEntry.create new_log_entry_attributes

    previous_log_entry.reload
    new_log_entry = affected_log_entries.select { |log_entry| log_entry.id != previous_log_entry.id }.first

    expect(LogEntry.count).to eq log_entry_count_before_new + 1

    if previous_log_entry.started_at < new_log_entry.started_at
      expect(previous_log_entry.finished_at).to eq new_log_entry.started_at
    else
      expect(previous_log_entry.started_at).to eq new_log_entry.finished_at
    end
  end
end

RSpec.configure do |config|
  config.include LogEntryHelpers
end
