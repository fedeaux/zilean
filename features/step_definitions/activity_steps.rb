Given(/^Some activities exist$/) do
  create_or_find_activity :activity_sleep
  create_or_find_activity :activity_work_project_dharma
  create_or_find_activity :activity_work_project_x
end
