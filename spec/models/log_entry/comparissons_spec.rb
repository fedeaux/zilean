require 'rails_helper'

RSpec.describe LogEntry, type: :model do
  describe '#collision_with' do
    let(:user) { create_or_find_user(:user_ray) }
    let(:existing_log_entry) { create :log_entry, started_at: time(3), finished_at: time(5) }

    context "the other started before" do
      let(:started_at) { time(1) }

      it 'returns false if the other log entry finished before this started' do
        new_log_entry = build :log_entry, started_at: started_at, finished_at: time(2)
        expect(existing_log_entry.collision_with new_log_entry).to eq false
      end

      it 'returns left if the other log entry finished at the time this started' do
        new_log_entry = build :log_entry, started_at: started_at, finished_at: time(3)
        expect(existing_log_entry.collision_with new_log_entry).to eq :left
      end

      it 'returns left if the other log entry finished between this' do
        new_log_entry = build :log_entry, started_at: started_at, finished_at: time(4)
        expect(existing_log_entry.collision_with new_log_entry).to eq :left
      end

      it 'returns wrapping if the other log entry finished together' do
        new_log_entry = build :log_entry, started_at: started_at, finished_at: time(5)
        expect(existing_log_entry.collision_with new_log_entry).to eq :wrapping
      end

      it 'returns wrapping if the other log entry finished after' do
        new_log_entry = build :log_entry, started_at: started_at, finished_at: time(6)
        expect(existing_log_entry.collision_with new_log_entry).to eq :wrapping
      end

    end

    context "the other started together" do
      let(:started_at) { time(3) }

      it 'returns left if the other log entry finished before' do
        new_log_entry = build :log_entry, started_at: started_at, finished_at: time(4)
        expect(existing_log_entry.collision_with new_log_entry).to eq :left
      end

      it 'returns wrapping if the other log entry started and finished together' do
        new_log_entry = build :log_entry, started_at: started_at, finished_at: time(5)
        expect(existing_log_entry.collision_with new_log_entry).to eq :wrapping
      end

      it 'returns wrapping if the other log entry started together and finished after' do
        new_log_entry = build :log_entry, started_at: started_at, finished_at: time(6)
        expect(existing_log_entry.collision_with new_log_entry).to eq :wrapping
      end
    end

    context "the other started between" do
      let(:started_at) { time(4) }

      it 'returns wrapped if the other log entry finished between' do
        new_log_entry = build :log_entry, started_at: started_at, finished_at: time(4.5)
        expect(existing_log_entry.collision_with new_log_entry).to eq :wrapped
      end

      it 'returns right if the other log entry finished together' do
        new_log_entry = build :log_entry, started_at: started_at, finished_at: time(5)
        expect(existing_log_entry.collision_with new_log_entry).to eq :right
      end

      it 'returns right if the other log entry finished after' do
        new_log_entry = build :log_entry, started_at: started_at, finished_at: time(6)
        expect(existing_log_entry.collision_with new_log_entry).to eq :right
      end
    end

    context "the other started at the time this finished" do
      it 'returns right' do
        new_log_entry = build :log_entry, started_at: time(5), finished_at: time(6)
        expect(existing_log_entry.collision_with new_log_entry).to eq :right
      end
    end

    context "the other started after this finished" do
      it 'returns false' do
        new_log_entry = build :log_entry, started_at: time(6), finished_at: time(7)
        expect(existing_log_entry.collision_with new_log_entry).to eq false
      end
    end
  end
end
