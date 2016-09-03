require 'net/http'

# if Rails.env.production?
  @uri = URI('http://zhonyas.herokuapp.com/digest')
# else
#   @uri = URI('http://localhost:3001/digest')
# end

response = JSON.parse(Net::HTTP.get(@uri))

response.each do |data|
  @user = User.find_by email: data['user']['email']
  next unless @user
  @user.log_entries.destroy_all
  @user.activities.destroy_all

  @activity_map = {}

  data['activities'].each do |activity|
    parts = activity['slug'].split(':')

    current_parent = nil
    parts.each_with_index do |slug, index|
      a = @user.activities.where(slug: slug).first_or_initialize

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
      current_parent = a
      @activity_map[activity['id']] = a
    end
  end

  data['log_entries'].each do |log_entry_attr|
    log_entry_attr['user_id'] = @user.id
    log_entry_attr['activity_id'] = @activity_map[log_entry_attr['activity_id']].id
    log_entry = LogEntry.create log_entry_attr
  end
end
