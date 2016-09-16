require 'rails_helper'

# time defined at spec/support/time_helpers.rb
# defined at spec/support/log_entry_helpers.rb
#   expect_log_entry_merge

RSpec.describe LogEntry, type: :model do
  describe '#create' do
    let(:user) { create_or_find_user(:user_ray) }
    let(:log_entry_attributes) { attributes_for :log_entry }

    context 'left and right collisions' do
      it 'merges the three log entries into one if mergeable left and right collision' do
        left_log_entry = LogEntry.create(log_entry_attributes.merge(started_at: time(0), finished_at: time(2))).first
        right_log_entry = LogEntry.create(log_entry_attributes.merge(started_at: time(4), finished_at: time(6))).first

        affected_log_entries = LogEntry.create log_entry_attributes.merge(started_at: time(2), finished_at: time(4))

        expect(LogEntry.count).to eq 1
        merged_log_entry = LogEntry.first

        right_log_entry.reload

        expect(affected_log_entries).to include right_log_entry

        expect(merged_log_entry.started_at).to eq time(0)
        expect(merged_log_entry.finished_at).to eq time(6)
      end

      it 'merges one and trim the other if mergeable left collision and trimable right collision' do
        left_log_entry = LogEntry.create(log_entry_attributes.merge(started_at: time(0), finished_at: time(2),
          activity: create_or_find_activity(:activity_work_project_x))).first

        right_log_entry = LogEntry.create(log_entry_attributes.merge(started_at: time(4), finished_at: time(6),
          activity: create_or_find_activity(:activity_work_project_dharma))).first

        affected_log_entries = LogEntry.create log_entry_attributes.merge(started_at: time(2), finished_at: time(5),
          activity: create_or_find_activity(:activity_work_project_x))

        expect(LogEntry.count).to eq 2
        left_log_entry.reload
        right_log_entry.reload

        expect(affected_log_entries).to include left_log_entry
        expect(affected_log_entries).to include right_log_entry

        expect(left_log_entry.started_at).to eq time(0)
        expect(left_log_entry.finished_at).to eq time(5)

        expect(right_log_entry.started_at).to eq time(5)
        expect(right_log_entry.finished_at).to eq time(6)
      end

      it 'trims one and merges with the other if trimable left collision and mergeable right collision' do
        left_log_entry = LogEntry.create(log_entry_attributes.merge(started_at: time(0), finished_at: time(2),
          activity: create_or_find_activity(:activity_work_project_dharma))).first

        right_log_entry = LogEntry.create(log_entry_attributes.merge(started_at: time(4), finished_at: time(6),
          activity: create_or_find_activity(:activity_work_project_x))).first

        affected_log_entries = LogEntry.create log_entry_attributes.merge(started_at: time(1), finished_at: time(5),
          activity: create_or_find_activity(:activity_work_project_x))

        expect(LogEntry.count).to eq 2
        left_log_entry.reload
        right_log_entry.reload

        expect(affected_log_entries).to include left_log_entry, right_log_entry

        expect(left_log_entry.started_at).to eq time(0)
        expect(left_log_entry.finished_at).to eq time(1)

        expect(right_log_entry.started_at).to eq time(1)
        expect(right_log_entry.finished_at).to eq time(6)
      end
    end

    context 'side and wrapped collisions' do
      it 'merges the three log entries into one if mergeable left and wrapped collision' do
        left_log_entry = LogEntry.create(log_entry_attributes.merge(started_at: time(0), finished_at: time(2))).first
        wrapped_log_entry = LogEntry.create(log_entry_attributes.merge(started_at: time(3), finished_at: time(5))).first

        affected_log_entries = LogEntry.create log_entry_attributes.merge(started_at: time(1), finished_at: time(5))
        wrapped_log_entry.reload

        expect(LogEntry.count).to eq 1
        expect(wrapped_log_entry.started_at).to eq time(0)
        expect(wrapped_log_entry.finished_at).to eq time(5)
        expect(affected_log_entries).to include wrapped_log_entry, left_log_entry
      end

      it 'merges the three log entries into one if mergeable wrapped and right collision' do
        wrapped_log_entry = LogEntry.create(log_entry_attributes.merge(started_at: time(3), finished_at: time(5))).first
        right_log_entry = LogEntry.create(log_entry_attributes.merge(started_at: time(7), finished_at: time(10))).first

        affected_log_entries = LogEntry.create log_entry_attributes.merge(started_at: time(1), finished_at: time(8))
        wrapped_log_entry.reload

        wrapped_log_entry.reload

        expect(LogEntry.count).to eq 1
        expect(wrapped_log_entry.started_at).to eq time(1)
        expect(wrapped_log_entry.finished_at).to eq time(10)
        expect(affected_log_entries).to include wrapped_log_entry, right_log_entry
      end
    end

    it 'survives even a lot of collisions' do
      left_log_entry = LogEntry.create(log_entry_attributes.merge(started_at: time(0), finished_at: time(2),
        activity: create_or_find_activity(:activity_work_project_x))).first

      wrapped_log_entry_1 = LogEntry.create(log_entry_attributes.merge(started_at: time(2), finished_at: time(3),
        activity: create_or_find_activity(:activity_work_project_dharma))).first

      wrapped_log_entry_2 = LogEntry.create(log_entry_attributes.merge(started_at: time(3), finished_at: time(4),
        activity: create_or_find_activity(:activity_work_project_x))).first

      wrapped_log_entry_3 = LogEntry.create(log_entry_attributes.merge(started_at: time(5), finished_at: time(7),
        activity: create_or_find_activity(:activity_work_project_x))).first

      right_log_entry = LogEntry.create(log_entry_attributes.merge(started_at: time(7), finished_at: time(10),
        activity: create_or_find_activity(:activity_work_project_dharma))).first

      affected_log_entries = LogEntry.create log_entry_attributes.merge(started_at: time(1), finished_at: time(9),
        activity: create_or_find_activity(:activity_work_project_x))

      expect(affected_log_entries).to include left_log_entry, wrapped_log_entry_1,
        wrapped_log_entry_2, wrapped_log_entry_3, right_log_entry

      wrapped_log_entry_3.reload
      right_log_entry.reload

      expect(wrapped_log_entry_3.started_at).to eq time(0)
      expect(wrapped_log_entry_3.finished_at).to eq time(9)

      expect(right_log_entry.started_at).to eq time(9)
      expect(right_log_entry.finished_at).to eq time(10)

      expect(LogEntry.count).to eq 2
    end
  end
end
