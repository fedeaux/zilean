require 'rails_helper'

# time defined at spec/support/time_helpers.rb
# defined at spec/support/log_entry_helpers.rb
#   expect_log_entry_merge

RSpec.describe LogEntry, type: :model do
  describe '#create' do
    let(:user) { create_or_find_user(:user_ray) }
    let(:log_entry_attributes) { attributes_for :log_entry }

    it 'creates a log entry' do
      expect{LogEntry.create attributes_for :log_entry}.to change{ LogEntry.count }.from(0).to(1)
    end

    context 'left collisions' do
      context 'same activity' do
        it 'expands a left collision with finished_at equals to started_at' do
          expect_log_entry_merge log_entry_attributes.merge( started_at: time(0), finished_at: time(1) ),
            log_entry_attributes.merge( started_at: time(1), finished_at: time(2) )
        end

        it 'expands a left collision with finished_at in the middle of the new task' do
          expect_log_entry_merge log_entry_attributes.merge( started_at: time(0), finished_at: time(2) ),
            log_entry_attributes.merge( started_at: time(1), finished_at: time(3) )
        end

        it 'expands a left collision with same finished_at' do
          expect_log_entry_merge log_entry_attributes.merge( started_at: time(0), finished_at: time(2) ),
            log_entry_attributes.merge( started_at: time(1), finished_at: time(2) )
        end
      end

      context 'different activities' do
        it 'creates a new log_entry (finished_at equals to started_at)' do
          expect_log_entry_trim(
            log_entry_attributes.merge(
              started_at: time(0), finished_at: time(1), activity: create_or_find_activity(:activity_work_project_x) ),

            log_entry_attributes.merge(
              started_at: time(1), finished_at: time(2), activity: create_or_find_activity(:activity_work_project_dharma) )

            )
        end

        it 'creates a new log_entry and trims finished_at (finished_at > started_at)' do
          expect_log_entry_trim(
            log_entry_attributes.merge(
              started_at: time(0), finished_at: time(2), activity: create_or_find_activity(:activity_work_project_x) ),

            log_entry_attributes.merge(
              started_at: time(1), finished_at: time(4), activity: create_or_find_activity(:activity_work_project_dharma) )

            )
        end
      end
    end

    context 'right collisions' do
      it 'expands a right collision with finished_at equals to started_at' do
        expect_log_entry_merge log_entry_attributes.merge( started_at: time(1), finished_at: time(2) ),
          log_entry_attributes.merge( started_at: time(0), finished_at: time(1) )
      end

      it 'expands a right collision with started_at in the middle of the new task' do
        expect_log_entry_merge log_entry_attributes.merge( started_at: time(1), finished_at: time(3) ),
          log_entry_attributes.merge( started_at: time(0), finished_at: time(2) )
      end

      it 'expands a left collision with same started_at' do
        expect_log_entry_merge log_entry_attributes.merge( started_at: time(0), finished_at: time(2) ),
          log_entry_attributes.merge( started_at: time(0), finished_at: time(1) )
      end
    end

    context 'wrapped collision' do
      it 'expands a wrapped collision if they share the activity' do
        expect_log_entry_merge log_entry_attributes.merge( started_at: time(1), finished_at: time(2) ),
          log_entry_attributes.merge( started_at: time(0), finished_at: time(3) )
      end

      it 'expands a wrapped collision if they share the activity (same time limits)' do
        expect_log_entry_merge log_entry_attributes.merge( started_at: time(1), finished_at: time(2) ),
          log_entry_attributes.merge( started_at: time(1), finished_at: time(2) )
      end
    end

    context 'wrapper collision' do
      it 'does nothing if they share the activity' do
        previous_log_entry = LogEntry.create(log_entry_attributes.merge( started_at: time(0), finished_at: time(5) )).first
        new_log_entry = LogEntry.create(log_entry_attributes.merge( started_at: time(1), finished_at: time(3) )).first

        previous_log_entry.reload
        expect(previous_log_entry.id).to eq new_log_entry.id
        expect(previous_log_entry.started_at).to eq time(0)
        expect(previous_log_entry.finished_at).to eq time(5)
      end

      it 'splits the previous log entry into two so the new log entry can fit in if they don\'t share the activity' do
        previous_log_entry = LogEntry.create(
          log_entry_attributes.merge( started_at: time(0), finished_at: time(5),
            activity: create_or_find_activity(:activity_work_project_x) )).first

        affected_log_entries = LogEntry.create(
          log_entry_attributes.merge( started_at: time(1), finished_at: time(3),
            activity: create_or_find_activity(:activity_work_project_dharma) ))

        previous_log_entry.reload

        new_log_entry = affected_log_entries.select { |log_entry|
          log_entry.activity_id != previous_log_entry.activity_id
        }.first

        split_log_entry = affected_log_entries.select { |log_entry|
          log_entry.activity_id == previous_log_entry.activity_id and
            log_entry.id != previous_log_entry.id
        }.first

        expect(previous_log_entry.started_at).to eq time(0)
        expect(previous_log_entry.finished_at).to eq time(1)

        expect(new_log_entry.started_at).to eq time(1)
        expect(new_log_entry.finished_at).to eq time(3)

        expect(split_log_entry.started_at).to eq time(3)
        expect(split_log_entry.finished_at).to eq time(5)
        expect(split_log_entry.activity_id).to eq previous_log_entry.activity_id
      end
    end
  end
end
