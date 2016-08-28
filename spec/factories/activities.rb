FactoryGirl.define do
  factory :activity do
    user { create_or_find_user :user_ray }
    color '#000'

    factory :activity_work do
      name 'Work'
      slug 'work'
    end

    factory :activity_work_project_x do
      name 'Project X'
      slug 'work:project_x'
      parent { create_or_find_activity :activity_work }
    end

    factory :activity_work_project_dharma do
      name 'Project Dharma'
      slug 'work:project_dharma'
      parent { create_or_find_activity :activity_work }
    end
  end
end
