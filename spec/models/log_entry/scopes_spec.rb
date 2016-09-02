require 'rails_helper'

RSpec.describe LogEntry, type: :model do
  describe 'scopes' do
    let(:user_ray) { create_or_find_user(:user_ray) }
    let(:user_steve) { create_or_find_user(:user_steve) }

    before :each do
      @log_entries = []
      @time_block_length = 4

      10.times do |days|
        @log_entries[days] = []

        5.times do |hours_block|
          total_hours = 24 * days + @time_block_length * hours_block
          user = hours_block.even? ? create_or_find_user(:user_ray) : create_or_find_user(:user_steve)

          @log_entries[days] << create(:log_entry, user: user, started_at: time(total_hours),
            finished_at: time(total_hours+@time_block_length))
        end
      end
    end

    it 'can fetch activities on a period' do
      log_entries = LogEntry.on_period(time(4), time(30)).to_a
      expect(log_entries.count).to eq (30-4)/4
      expect(log_entries).to include(*(@log_entries[0][1..-1] + @log_entries[1][0, 2]))
    end

    it 'can fetch activities on a day' do
      log_entries = LogEntry.on_day(time(4)).to_a
      expect(log_entries).to include(*@log_entries[0])
      expect(log_entries.count).to eq @log_entries[0].count

      log_entries = LogEntry.on_day(time(50)).to_a
      expect(log_entries).to include(*@log_entries[2])
      expect(log_entries.count).to eq @log_entries[2].count
    end
  end
end
