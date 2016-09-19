require 'rails_helper'

RSpec.describe Report, type: :model do
  describe '#log_entries' do
    before :each do
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

    it 'fetches all log entries within the activities' do
      report = create :report, activities: [@activity_work_project_x]
      expect(report.log_entries.count).to eq LogEntry.where(activity_id: @activity_work_project_x.id).count
    end

    it 'fetches all log entries within the activities, including children activities' do
      report = create :report, activities: [@activity_work]
      expect(report.log_entries.count).to eq LogEntry.count
    end

    it 'fetches all log entries within the activities, respecting start time' do
      report = create :report, activities: [@activity_work_project_x], start: time(24)

      expect(report.log_entries.count).to eq LogEntry.
        where("activity_id = :activity_id AND started_at >= :start",
               activity_id: @activity_work_project_x.id, start: time(24)).count
    end

    it 'fetches all log entries within the activities, respecting finish time' do
      report = create :report, activities: [@activity_work_project_x], finish: time(48)

      expect(report.log_entries.count).to eq LogEntry.
        where("activity_id = :activity_id AND finished_at <= :finish",
               activity_id: @activity_work_project_x.id, finish: time(48)).count
    end

    it 'fetches all log entries within the activities, respecting both start and finish time' do
      report = create :report, activities: [@activity_work_project_x], start: time(24), finish: time(48)

      expect(report.log_entries.count).to eq LogEntry.
        where("activity_id = :activity_id AND started_at >= :start AND finished_at <= :finish",
        activity_id: @activity_work_project_x.id,
        start: time(24),
        finish: time(48)).count
    end
  end
end
