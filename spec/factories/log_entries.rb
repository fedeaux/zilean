FactoryGirl.define do
  factory :log_entry do
    user nil
    activity nil
    started_at "2016-09-01 10:42:41"
    finished_at "2016-09-01 10:42:41"
    observations "MyText"
  end
end
