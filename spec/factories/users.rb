FactoryGirl.define do
  factory :user_ray, class: :user do
    email 'charles@ray.com'
    password 'defaultpassword'
    password_confirmation 'defaultpassword'
  end

  factory :user_steve, class: :user do
    email 'wonder@steve.com'
    password 'defaultpassword'
    password_confirmation 'defaultpassword'
  end
end
