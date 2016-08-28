FactoryGirl.define do
  factory :user_ray, class: :user do
    email 'charles@ray.com'
    password 'defaultpassword'
    password_confirmation 'defaultpassword'
  end
end
