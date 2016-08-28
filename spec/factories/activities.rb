FactoryGirl.define do
  factory :activity do
    user { create_or_find_user :user_ray }

    factory :activity_work do
      name 'Work'
      slug 'work'
      color '#000'
    end

    factory :activity_work_project_x do
      name 'Project X'
      slug 'project_x'
      parent { create_or_find_activity :activity_work }
      color '#333'
    end

    factory :activity_work_project_dharma do
      name 'Project Dharma'
      slug 'project_dharma'
      parent { create_or_find_activity :activity_work }
      color '#666'
    end
  end
end
