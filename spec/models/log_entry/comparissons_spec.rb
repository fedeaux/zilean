require 'rails_helper'

RSpec.describe LogEntry, type: :model do
  describe '#colliding_log_entries' do
    let(:user) { create_or_find_user(:user_ray) }

    context 'one collision' do
      it 'returns log entries that finished at the moment this log entry started' do
        existing_log_entry = create :log_entry, started_at: time(0), finished_at: time(1)
        new_log_entry = build :log_entry, started_at: time(1), finished_at: time(2)
        collisions = new_log_entry.colliding_log_entries
        expect(collisions[:left]).to include existing_log_entry
        expect(collisions.except(:left).values.flatten.uniq).to eq []
      end

      it 'returns log entries that started before this log entry and finished between' do
        existing_log_entry = create :log_entry, started_at: time(0), finished_at: time(2)
        new_log_entry = build :log_entry, started_at: time(1), finished_at: time(3)
        collisions = new_log_entry.colliding_log_entries
        expect(collisions[:left]).to include existing_log_entry
        expect(collisions.except(:left).values.flatten.uniq).to eq []
      end

      it 'returns log entries that started at the moment this log entry finished' do
        existing_log_entry = create :log_entry, started_at: time(1), finished_at: time(2)
        new_log_entry = build :log_entry, started_at: time(0), finished_at: time(1)
        collisions = new_log_entry.colliding_log_entries
        expect(collisions[:right]).to include existing_log_entry
        expect(collisions.except(:right).values.flatten.uniq).to eq []
      end

      it 'returns log entries that started between this log entry and finished after' do
        existing_log_entry = create :log_entry, started_at: time(1), finished_at: time(3)
        new_log_entry = build :log_entry, started_at: time(0), finished_at: time(2)
        collisions = new_log_entry.colliding_log_entries
        expect(collisions[:right]).to include existing_log_entry
        expect(collisions.except(:right).values.flatten.uniq).to eq []
      end

      it 'returns log entries that wraps this log entry' do
        existing_log_entry = create :log_entry, started_at: time(0), finished_at: time(3)
        new_log_entry = build :log_entry, started_at: time(1), finished_at: time(2)
        collisions = new_log_entry.colliding_log_entries
        expect(collisions[:wrapper]).to include existing_log_entry
        expect(collisions.except(:wrapper).values.flatten.uniq).to eq []
      end

      it 'returns log entries that are wrapped by this log entry' do
        existing_log_entry = create :log_entry, started_at: time(1), finished_at: time(2)
        new_log_entry = build :log_entry, started_at: time(0), finished_at: time(3)
        collisions = new_log_entry.colliding_log_entries
        expect(collisions[:wrapped]).to include existing_log_entry
        expect(collisions.except(:wrapped).values.flatten.uniq).to eq []
      end

      it 'returns log entries that are wrapped by this log entry, even with same start time' do
        existing_log_entry = create :log_entry, started_at: time(0), finished_at: time(2)
        new_log_entry = build :log_entry, started_at: time(0), finished_at: time(3)
        collisions = new_log_entry.colliding_log_entries
        expect(collisions[:wrapped]).to include existing_log_entry
        expect(collisions.except(:wrapped).values.flatten.uniq).to eq []
      end

      it 'returns log entries that are wrapped by this log entry, even with same finish time' do
        existing_log_entry = create :log_entry, started_at: time(1), finished_at: time(2)
        new_log_entry = build :log_entry, started_at: time(0), finished_at: time(2)
        collisions = new_log_entry.colliding_log_entries
        expect(collisions[:wrapped]).to include existing_log_entry
        expect(collisions.except(:wrapped).values.flatten.uniq).to eq []
      end

      it 'returns log entries that have the same start and finish time' do
        existing_log_entry = create :log_entry, started_at: time(1), finished_at: time(2)
        new_log_entry = build :log_entry, started_at: time(1), finished_at: time(2)
        collisions = new_log_entry.colliding_log_entries
        expect(collisions[:wrapped]).to include existing_log_entry
        expect(collisions.except(:wrapped).values.flatten.uniq).to eq []
      end
    end

    context 'multiple collisions' do
      before :each do
        @existing_log_entry_1 = create :log_entry, started_at: time(0), finished_at: time(2)
        @existing_log_entry_2 = create :log_entry, started_at: time(3), finished_at: time(5)
      end

      it 'can detect left and right collisions simultaneously' do
        new_log_entry = build :log_entry, started_at: time(1), finished_at: time(4)
        collisions = new_log_entry.colliding_log_entries
        expect(collisions[:left]).to include @existing_log_entry_1
        expect(collisions[:right]).to include @existing_log_entry_2
        expect(collisions.except(:left, :right).values.flatten.uniq).to eq []
      end

      it 'can detect left and wrapped collisions simultaneously' do
        new_log_entry = build :log_entry, started_at: time(1), finished_at: time(5)
        collisions = new_log_entry.colliding_log_entries
        expect(collisions[:left]).to include @existing_log_entry_1
        expect(collisions[:wrapped]).to include @existing_log_entry_2
        expect(collisions.except(:left, :wrapped).values.flatten.uniq).to eq []
      end

      it 'can detect multiple wrapped collisions' do
        new_log_entry = build :log_entry, started_at: time(0), finished_at: time(5)
        collisions = new_log_entry.colliding_log_entries
        expect(collisions[:wrapped]).to include @existing_log_entry_1
        expect(collisions[:wrapped]).to include @existing_log_entry_2
        expect(collisions.except(:wrapped).values.flatten.uniq).to eq []
      end
    end
  end
end
