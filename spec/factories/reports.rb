FactoryGirl.define do
  factory :report do
    user { create_or_find_user :user_ray }
    metrics []
    start nil
    finish nil
    weekdays [0, 1, 2, 3, 4, 5, 6]
  end
end
