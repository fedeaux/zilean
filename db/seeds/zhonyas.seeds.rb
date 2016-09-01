require 'net/http'

if Rails.env.production?
  @uri = URI('http://zhonyas.herokuapp.com/digest')
else
  @uri = URI('http://localhost:3001/digest')
end

response = JSON.parse(Net::HTTP.get(@uri))

response.each do |data|
  @user = User.find_by email: data['user']['email']
  next unless @user
  @user.activities.destroy_all

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
    end
  end
end
