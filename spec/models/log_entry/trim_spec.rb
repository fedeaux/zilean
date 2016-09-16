require 'rails_helper'

RSpec.describe LogEntry, type: :model do
  describe '.create mergeable log_entry' do
    let(:user) { create_or_find_user(:user_ray) }
    let(:attr) { attributes_for(:log_entry, activity: create_or_find_activity(:activity_work_project_x)) }

    before(:each) do
      @existing_log_entry = create :log_entry, started_at: time(3), finished_at: time(5), activity: create_or_find_activity(:activity_sleep)
    end

    context "the other started before" do
      let(:started_at) { time(1) }

      it 'creates a new log_entry if the other log entry finished before this started' do
        affected_log_entries = LogEntry.create(attr.merge(started_at: started_at, finished_at: time(2)))
        expect(LogEntry.count).to eq 2
      end

      it 'creates a affected log_entries if the other log entry finished at the time this started' do
        affected_log_entries = LogEntry.create(attr.merge(started_at: started_at, finished_at: time(3)))

        expect(LogEntry.count).to eq 2
      end

      it 'increases this started_at if the other log entry finished between this' do
        affected_log_entries = LogEntry.create(attr.merge(started_at: started_at, finished_at: time(4)))

        expect(LogEntry.count).to eq 2
        expect(affected_log_entries).to include @existing_log_entry

        new_log_entry = affected_log_entries.select{ |log_entry| log_entry.id != @existing_log_entry.id }.first

        expect(LogEntry.count).to eq 2
        expect(new_log_entry.started_at).to eq started_at
        expect(new_log_entry.finished_at).to eq time(4)

        @existing_log_entry.reload
        expect(@existing_log_entry.started_at).to eq time(4)
        expect(@existing_log_entry.finished_at).to eq time(5)
      end

      it 'destroys this if the other log entry finished together' do
        affected_log_entries = LogEntry.create(attr.merge(started_at: started_at, finished_at: time(5)))

        expect(LogEntry.count).to eq 1
        expect(affected_log_entries).to include @existing_log_entry

        new_log_entry = affected_log_entries.select{ |log_entry| log_entry.id != @existing_log_entry.id }.first

        expect(LogEntry.exists? @existing_log_entry.id).to eq false

        expect(new_log_entry.started_at).to eq started_at
        expect(new_log_entry.finished_at).to eq time(5)
      end

      it 'destroys this if the other log entry finished after' do
        affected_log_entries = LogEntry.create(attr.merge(started_at: started_at, finished_at: time(6)))

        expect(LogEntry.count).to eq 1
        expect(affected_log_entries).to include @existing_log_entry

        new_log_entry = affected_log_entries.select{ |log_entry| log_entry.id != @existing_log_entry.id }.first

        expect(LogEntry.exists? @existing_log_entry.id).to eq false

        expect(new_log_entry.started_at).to eq started_at
        expect(new_log_entry.finished_at).to eq time(6)
      end
    end

    context "the other started together" do
      let(:started_at) { time(3) }

      it 'increases this started_at if the other log entry finished before' do
        affected_log_entries = LogEntry.create(attr.merge(started_at: started_at, finished_at: time(4)))

        expect(LogEntry.count).to eq 2
        expect(affected_log_entries).to include @existing_log_entry

        new_log_entry = affected_log_entries.select{ |log_entry| log_entry.id != @existing_log_entry.id }.first

        expect(LogEntry.count).to eq 2
        expect(new_log_entry.started_at).to eq started_at
        expect(new_log_entry.finished_at).to eq time(4)

        @existing_log_entry.reload
        expect(@existing_log_entry.started_at).to eq time(4)
        expect(@existing_log_entry.finished_at).to eq time(5)
      end

      it 'destroys this if the other log entry started and finished together' do
        affected_log_entries = LogEntry.create(attr.merge(started_at: started_at, finished_at: time(5)))

        expect(LogEntry.count).to eq 1
        expect(affected_log_entries).to include @existing_log_entry

        new_log_entry = affected_log_entries.select{ |log_entry| log_entry.id != @existing_log_entry.id }.first

        expect(LogEntry.exists? @existing_log_entry.id).to eq false

        expect(new_log_entry.started_at).to eq started_at
        expect(new_log_entry.finished_at).to eq time(5)
      end

      it 'destroys this if the other log entry started together and finished after' do
        affected_log_entries = LogEntry.create(attr.merge(started_at: started_at, finished_at: time(6)))

        expect(LogEntry.count).to eq 1
        expect(affected_log_entries).to include @existing_log_entry

        new_log_entry = affected_log_entries.select{ |log_entry| log_entry.id != @existing_log_entry.id }.first

        expect(LogEntry.exists? @existing_log_entry.id).to eq false

        expect(new_log_entry.started_at).to eq started_at
        expect(new_log_entry.finished_at).to eq time(6)
      end
    end

    context "the other started between" do
      let(:started_at) { time(4) }

      it 'splits this into two new log_entries if the other log entry finished between' do
        affected_log_entries = LogEntry.create(attr.merge(started_at: started_at, finished_at: time(4.5)))

        expect(affected_log_entries).to include @existing_log_entry

        split_log_entry = affected_log_entries.select{ |log_entry| log_entry.started_at == time(4.5) }.first
        new_log_entry = affected_log_entries.select{ |log_entry| log_entry.started_at == started_at }.first

        @existing_log_entry.reload

        expect(LogEntry.count).to eq 3

        expect(@existing_log_entry.started_at).to eq time(3)
        expect(@existing_log_entry.finished_at).to eq started_at

        expect(new_log_entry.started_at).to eq started_at
        expect(new_log_entry.finished_at).to eq time(4.5)

        expect(split_log_entry.started_at).to eq time(4.5)
        expect(split_log_entry.finished_at).to eq time(5)
      end

      it 'decreases this finished_at if the other log entry finished together' do
        affected_log_entries = LogEntry.create(attr.merge(started_at: started_at, finished_at: time(5)))

        expect(LogEntry.count).to eq 2
        expect(affected_log_entries).to include @existing_log_entry

        new_log_entry = affected_log_entries.select{ |log_entry| log_entry.id != @existing_log_entry.id }.first

        expect(LogEntry.count).to eq 2
        expect(new_log_entry.started_at).to eq started_at
        expect(new_log_entry.finished_at).to eq time(5)

        @existing_log_entry.reload
        expect(@existing_log_entry.started_at).to eq time(3)
        expect(@existing_log_entry.finished_at).to eq started_at
      end

      it 'decreases this finished_at if the other log entry finished after' do
        affected_log_entries = LogEntry.create(attr.merge(started_at: started_at, finished_at: time(6)))

        expect(LogEntry.count).to eq 2
        expect(affected_log_entries).to include @existing_log_entry

        new_log_entry = affected_log_entries.select{ |log_entry| log_entry.id != @existing_log_entry.id }.first

        expect(LogEntry.count).to eq 2
        expect(new_log_entry.started_at).to eq started_at
        expect(new_log_entry.finished_at).to eq time(6)

        @existing_log_entry.reload
        expect(@existing_log_entry.started_at).to eq time(3)
        expect(@existing_log_entry.finished_at).to eq started_at
      end
    end

    context "the other started at the time this finished" do
      it 'creates a new log_entry' do
        affected_log_entries = LogEntry.create(attr.merge(started_at: time(5), finished_at: time(6)))
        expect(LogEntry.count).to eq 2
      end
    end

    context "the other started after this finished" do
      it 'creates a new log entry' do
        affected_log_entries = LogEntry.create(attr.merge(started_at: time(6), finished_at: time(7)))
        expect(LogEntry.count).to eq 2
      end
    end
  end
end
