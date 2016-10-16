require 'net/http'

@uri = URI('http://zilean.herokuapp.com/digest')

response = JSON.parse(Net::HTTP.get(@uri))

LogEntry.destroy_all
Activity.destroy_all
ActiveRecord::Base.connection.execute('ALTER SEQUENCE activities_id_seq RESTART WITH 1')
ActiveRecord::Base.connection.execute('ALTER SEQUENCE log_entries_id_seq RESTART WITH 1')

response.each do |data|
  @user = User.find_by email: data['user']['email']
  next unless @user

  data['activities'].each do |activity|
    Activity.create activity
  end

  data['log_entries'].each do |log_entry_attr|
    LogEntry.create log_entry_attr
  end
end

ActiveRecord::Base.connection.execute("ALTER SEQUENCE activities_id_seq RESTART WITH #{Activity.pluck(:id).max + 1}")
ActiveRecord::Base.connection.execute("ALTER SEQUENCE log_entries_id_seq RESTART WITH #{LogEntry.pluck(:id).max + 1}")
