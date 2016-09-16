require 'rails_helper'

RSpec.describe LogEntry, type: :model do
  describe '#colliding_log_entries' do
    let(:user) { create_or_find_user(:user_ray) }
    context 'multiple collisions' do
      before :each do
        @existing_log_entry_1 = create :log_entry, started_at: time(0), finished_at: time(2)
        @existing_log_entry_2 = create :log_entry, started_at: time(3), finished_at: time(5)
      end

      it 'can detect left and right collisions simultaneously' do
        new_log_entry = build :log_entry, started_at: time(1), finished_at: time(4)
        collisions = new_log_entry.colliding_log_entries

        expect(collisions).to include @existing_log_entry_1, @existing_log_entry_2
        expect(@existing_log_entry_1.collision_with new_log_entry).to eq :right
        expect(@existing_log_entry_2.collision_with new_log_entry).to eq :left
      end

      it 'can detect left and wrapper collisions simultaneously' do
        new_log_entry = build :log_entry, started_at: time(1), finished_at: time(5)
        collisions = new_log_entry.colliding_log_entries

        expect(collisions).to include @existing_log_entry_1, @existing_log_entry_2
        expect(@existing_log_entry_1.collision_with new_log_entry).to eq :right
        expect(@existing_log_entry_2.collision_with new_log_entry).to eq :wrapping
      end

      it 'can detect multiple wrapper collisions' do
        new_log_entry = build :log_entry, started_at: time(0), finished_at: time(5)
        collisions = new_log_entry.colliding_log_entries

        expect(collisions).to include @existing_log_entry_1, @existing_log_entry_2
        expect(@existing_log_entry_1.collision_with new_log_entry).to eq :wrapping
        expect(@existing_log_entry_2.collision_with new_log_entry).to eq :wrapping
      end
    end
  end
end
