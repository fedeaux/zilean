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

      it 'on wrapper collision, delete the log_entry' do
        first_log_entry = create :log_entry, started_at: time(1), finished_at: time(2)
        second_log_entry = build :log_entry, started_at: time(0), finished_at: time(3)

        first_log_entry.trim second_log_entry

        expect(LogEntry.exists? first_log_entry.id).to be false
      end

      it 'on wrapped collision, raise an error' do
        first_log_entry = create :log_entry, started_at: time(0), finished_at: time(3)
        second_log_entry = build :log_entry, started_at: time(1), finished_at: time(2)

        expect{ first_log_entry.trim second_log_entry }.to raise_error(RuntimeError)
      end
    end
  end
end
