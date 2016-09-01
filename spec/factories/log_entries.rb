FactoryGirl.define do
  factory :log_entry do
    user { create_or_find_user :user_ray }
    activity { create_or_find_activity :activity_work_project_x }
    started_at "2016-09-01 10:42:41"
    finished_at "2016-09-01 10:42:41"
    observations ""
  end
end
