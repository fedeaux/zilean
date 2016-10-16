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

  def create_work_log_entries_spanning_ten_days
    @activity_work_project_x = create_or_find_activity(:activity_work_project_x)
    @activity_work_project_dharma = create_or_find_activity(:activity_work_project_dharma)
    @activity_work = create_or_find_activity(:activity_work)

    activities = [@activity_work_project_x, @activity_work_project_dharma, @activity_work]
    activity_index = 0

    time_range( hours_offsets: [0, 3, 12, 18], days: 10 ).each do |time_obj|
      activity = activities[activity_index]
      activity_index = (activity_index + 1) % activities.length

      create :log_entry, started_at: time_obj, finished_at: time_obj + 2.hours, activity: activity
    end
  end

  def create_sleep_log_entries_spanning_ten_days
    @activity_sleep = create_or_find_activity :activity_sleep

    duration_noise = [-1.hour, 0.5.hours, 1.5.hours]
    started_at_noise = [-2.hour, 0, 1.hour, 0.5.hours]

    duration_noise_index = 0
    started_at_noise_index = 0

    time_range( hours_offsets: [22], days: 10 ).each do |time_obj|
      create :log_entry, started_at: time_obj + started_at_noise[started_at_noise_index],
        finished_at: time_obj + 7.5.hours + duration_noise[duration_noise_index],
        activity: @activity_sleep

      duration_noise_index = (duration_noise_index + 1) % duration_noise.length
      started_at_noise_index = (started_at_noise_index + 1) % started_at_noise.length
    end
  end
end

RSpec.configure do |config|
  config.include LogEntryHelpers
end
