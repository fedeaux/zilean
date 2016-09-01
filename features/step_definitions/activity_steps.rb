Given(/^Some activities exist$/) do
  create_or_find_activity :activity_sleep
  create_or_find_activity :activity_work_project_dharma
  create_or_find_activity :activity_work_project_x
end

Given(/^These activities exist$/) do |table|
  table.hashes.each do |activity_data|
    activity_data[:user] = create_or_find_user :user_ray
    Activity.create activity_data
  end
end
