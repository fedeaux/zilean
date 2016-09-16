require 'rails_helper'

RSpec.describe LogEntry, type: :model do
  describe '.crop' do
    let(:user) { create_or_find_user(:user_ray) }
    let(:log_entry_attributes) { attributes_for :log_entry }

    it 'crops log entries around a given time range' do
      log_entry_1 = LogEntry.create(
        log_entry_attributes.merge( started_at: time(0), finished_at: time(5),
          activity: create_or_find_activity(:activity_work_project_x) )).first

      log_entry_2 = LogEntry.create(
        log_entry_attributes.merge( started_at: time(6), finished_at: time(10),
          activity: create_or_find_activity(:activity_work_project_dharma) )).first

      affected_log_entries = LogEntry.crop time(3), time(8), user

      log_entry_1.reload
      log_entry_2.reload

      expect(log_entry_1.started_at).to eq time(0)
      expect(log_entry_2.started_at).to eq time(8)

      expect(log_entry_1.finished_at).to eq time(3)
      expect(log_entry_2.finished_at).to eq time(10)

      expect(affected_log_entries).to include log_entry_1, log_entry_2
    end

    it 'destroys log entries completelly contained on the time range' do
      log_entry_1 = LogEntry.create(
        log_entry_attributes.merge( started_at: time(0), finished_at: time(2))).first

      log_entry_2 = LogEntry.create(
        log_entry_attributes.merge( started_at: time(3), finished_at: time(5))).first

      log_entry_3 = LogEntry.create(
        log_entry_attributes.merge( started_at: time(6), finished_at: time(8))).first

      affected_log_entries = LogEntry.crop time(1), time(7), user

      log_entry_1.reload
      log_entry_3.reload

      expect(log_entry_1.started_at).to eq time(0)
      expect(log_entry_3.started_at).to eq time(7)

      expect(log_entry_1.finished_at).to eq time(1)
      expect(log_entry_3.finished_at).to eq time(8)

      expect(LogEntry.exists? log_entry_2.id).to eq false

      expect(affected_log_entries).to include log_entry_1, log_entry_2, log_entry_3
    end

    it 'destroys log entries that match the time range' do
      log_entry_1 = LogEntry.create(
        log_entry_attributes.merge( started_at: time(3), finished_at: time(4))).first

      affected_log_entries = LogEntry.crop time(3), time(4), user
      expect(LogEntry.exists? log_entry_1.id).to eq false
      expect(affected_log_entries).to include log_entry_1
    end
  end
end
