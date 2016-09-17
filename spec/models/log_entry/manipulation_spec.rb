require 'rails_helper'

RSpec.describe LogEntry, type: :model do
  describe '#colliding_log_entries' do
    let(:user) { create_or_find_user(:user_ray) }

    describe '#trim' do
      it 'on right collision, lowers the finished_at' do
        first_log_entry = build :log_entry, started_at: time(0), finished_at: time(2)
        second_log_entry = build :log_entry, started_at: time(1), finished_at: time(3)

        first_log_entry.trim second_log_entry

        expect(first_log_entry.finished_at).to eq time(1)
      end

      it 'on left collision, increases the started_at' do
        first_log_entry = build :log_entry, started_at: time(1), finished_at: time(3)
        second_log_entry = build :log_entry, started_at: time(0), finished_at: time(2)

        first_log_entry.trim second_log_entry

        expect(first_log_entry.started_at).to eq time(2)
      end

      it 'on wrapped collision, create a new log entry to leave a hole between those two equals to the size of the new log entry' do
        first_log_entry = create :log_entry, started_at: time(0), finished_at: time(3)
        second_log_entry = build :log_entry, started_at: time(1), finished_at: time(2)

        affected_log_entries = first_log_entry.trim second_log_entry
        created_log_entry = affected_log_entries.select{ |log_entry| log_entry.id != first_log_entry.id }.first
        first_log_entry.reload

        expect(first_log_entry.started_at).to eq time(0)
        expect(first_log_entry.finished_at).to eq time(1)
        expect(created_log_entry.started_at).to eq time(2)
        expect(created_log_entry.finished_at).to eq time(3)
      end

      context 'wrapper collision' do
        it 'destroys the log_entry, collision is greater on both sides' do
          first_log_entry = create :log_entry, started_at: time(1), finished_at: time(2)
          second_log_entry = build :log_entry, started_at: time(0), finished_at: time(3)

          first_log_entry.trim second_log_entry

          expect(LogEntry.exists? first_log_entry.id).to be false
        end

        it 'destroys the log_entry, collision matches left' do
          first_log_entry = create :log_entry, started_at: time(1), finished_at: time(2)
          second_log_entry = build :log_entry, started_at: time(1), finished_at: time(3)

          first_log_entry.trim second_log_entry

          expect(LogEntry.exists? first_log_entry.id).to be false
        end

        it 'destroys the log_entry, collision matches right' do
          first_log_entry = create :log_entry, started_at: time(2), finished_at: time(3)
          second_log_entry = build :log_entry, started_at: time(1), finished_at: time(3)

          first_log_entry.trim second_log_entry

          expect(LogEntry.exists? first_log_entry.id).to be false
        end

        it 'destroys the log_entry, collision matches both sides' do
          first_log_entry = create :log_entry, started_at: time(1), finished_at: time(2)
          second_log_entry = build :log_entry, started_at: time(1), finished_at: time(2)

          first_log_entry.trim second_log_entry

          expect(LogEntry.exists? first_log_entry.id).to be false
        end
      end
    end
  end
end
