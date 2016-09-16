require 'rails_helper'

RSpec.describe LogEntry, type: :model do
  describe '.create mergeable log_entry' do
    let(:user) { create_or_find_user(:user_ray) }
    let(:attr) { attributes_for(:log_entry) }

    before(:each) do
      @existing_log_entry = create :log_entry, started_at: time(3), finished_at: time(5)
    end

    context "the other started before" do
      let(:started_at) { time(1) }

      it 'creates a new log_entry if the other log entry finished before this started' do
        new_log_entry = LogEntry.create(attr.merge(started_at: started_at, finished_at: time(2))).first
        expect(LogEntry.count).to eq 2
      end

      it 'merges if the other log entry finished at the time this started' do
        new_log_entry = LogEntry.create(attr.merge(started_at: started_at, finished_at: time(3))).first

        expect(LogEntry.count).to eq 1
        expect(new_log_entry.started_at).to eq started_at
        expect(new_log_entry.finished_at).to eq time(5)
      end

      it 'merges if the other log entry finished between this' do
        new_log_entry = LogEntry.create(attr.merge(started_at: started_at, finished_at: time(4))).first

        expect(LogEntry.count).to eq 1
        expect(new_log_entry.started_at).to eq started_at
        expect(new_log_entry.finished_at).to eq time(5)
      end

      it 'merges if the other log entry finished together' do
        new_log_entry = LogEntry.create(attr.merge(started_at: started_at, finished_at: time(5))).first

        expect(LogEntry.count).to eq 1
        expect(new_log_entry.started_at).to eq started_at
        expect(new_log_entry.finished_at).to eq time(5)
      end

      it 'merges if the other log entry finished after' do
        new_log_entry = LogEntry.create(attr.merge(started_at: started_at, finished_at: time(6))).first

        expect(LogEntry.count).to eq 1
        expect(new_log_entry.started_at).to eq started_at
        expect(new_log_entry.finished_at).to eq time(6)
      end
    end

    context "the other started together" do
      let(:started_at) { time(3) }

      it 'merges if the other log entry finished before' do
        new_log_entry = LogEntry.create(attr.merge(started_at: started_at, finished_at: time(4))).first

        expect(LogEntry.count).to eq 1
        expect(new_log_entry.started_at).to eq started_at
        expect(new_log_entry.finished_at).to eq time(5)
      end

      it 'merges if the other log entry started and finished together' do
        new_log_entry = LogEntry.create(attr.merge(started_at: started_at, finished_at: time(5))).first

        expect(LogEntry.count).to eq 1
        expect(new_log_entry.started_at).to eq started_at
        expect(new_log_entry.finished_at).to eq time(5)
      end

      it 'merges wrapping if the other log entry started together and finished after' do
        new_log_entry = LogEntry.create(attr.merge(started_at: started_at, finished_at: time(6))).first

        expect(LogEntry.count).to eq 1
        expect(new_log_entry.started_at).to eq started_at
        expect(new_log_entry.finished_at).to eq time(6)
      end
    end

    context "the other started between" do
      let(:started_at) { time(4) }

      it 'merges if the other log entry finished between' do
        new_log_entry = LogEntry.create(attr.merge(started_at: started_at, finished_at: time(4.5))).first

        expect(LogEntry.count).to eq 1
        expect(new_log_entry.started_at).to eq time(3)
        expect(new_log_entry.finished_at).to eq time(5)
      end

      it 'merges if the other log entry finished together' do
        new_log_entry = LogEntry.create(attr.merge(started_at: started_at, finished_at: time(5))).first

        expect(LogEntry.count).to eq 1
        expect(new_log_entry.started_at).to eq time(3)
        expect(new_log_entry.finished_at).to eq time(5)
      end

      it 'merges if the other log entry finished after' do
        new_log_entry = LogEntry.create(attr.merge(started_at: started_at, finished_at: time(6))).first

        expect(LogEntry.count).to eq 1
        expect(new_log_entry.started_at).to eq time(3)
        expect(new_log_entry.finished_at).to eq time(6)
      end
    end

    context "the other started at the time this finished" do
      it 'merges' do
        new_log_entry = LogEntry.create(attr.merge(started_at: time(5), finished_at: time(6))).first

        expect(LogEntry.count).to eq 1
        expect(new_log_entry.started_at).to eq time(3)
        expect(new_log_entry.finished_at).to eq time(6)
      end
    end

    context "the other started after this finished" do
      it 'creates a new log entry' do
        new_log_entry = LogEntry.create(attr.merge(started_at: time(6), finished_at: time(7))).first

        expect(LogEntry.count).to eq 2
      end
    end
  end
end
