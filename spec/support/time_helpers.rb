module TimeHelpers
  def time(hours_offset)
    time = DateTime.new(2000, 1, 1, 0, 0, 0)

    return time if hours_offset == nil
    time + hours_offset.hours
  end

  def time_range( hours_offsets: [], days: 1 )
    (0..days).map { |day_offset|
      hours_offsets.map { |hour_offset|
        time(hour_offset + day_offset * 24)
      }
    }.flatten
  end
end

RSpec.configure do |config|
  config.include TimeHelpers
end
