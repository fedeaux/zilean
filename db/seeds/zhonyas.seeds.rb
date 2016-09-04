require 'net/http'

@uri = URI('http://zhonyas.herokuapp.com/digest')

response = JSON.parse(Net::HTTP.get(@uri))

LogEntry.destroy_all
Activity.destroy_all
ActiveRecord::Base.connection.execute('ALTER SEQUENCE activities_id_seq RESTART WITH 1')

response.each do |data|
  @user = User.find_by email: data['user']['email']
  next unless @user

  @activity_map = {}

  data['activities'].each do |activity|
    parts = activity['slug'].split(':')

    current_parent = nil
    parts.each_with_index do |slug, index|
      a = Activity.new slug: slug

      if index < parts.length - 1
        a.name = slug.titleize unless a.name
        a.color = activity['color'] unless a.color
      else
        a.name = activity['name']
        a.color = activity['color']
      end

      a.parent = current_parent
      a.user = @user
      a.save

      ap a.errors.inspect unless a.valid?
      current_parent = a
      @activity_map[activity['id']] = a
    end
  end

  data['log_entries'].each do |log_entry_attr|
    if @activity_map[log_entry_attr['activity_id']]
      log_entry_attr['user_id'] = @user.id
      log_entry_attr['activity_id'] = @activity_map[log_entry_attr['activity_id']].id
      log_entry = LogEntry.create log_entry_attr
    end
  end

  ActiveRecord::Base.connection.execute('ALTER SEQUENCE log_entries_id_seq RESTART WITH 1')
end
