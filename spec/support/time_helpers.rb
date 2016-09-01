module TimeHelpers
  def time(hours_offset)
    time = DateTime.new(2000, 1, 1, 0, 0, 0)

    return time if hours_offset == nil
    time + hours_offset.hours
  end
end

RSpec.configure do |config|
  config.include TimeHelpers
end
