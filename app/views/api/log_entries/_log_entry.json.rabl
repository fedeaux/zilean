attributes :id, :started_at, :finished_at, :duration, :observations

child :activity do
  attributes :id, :name, :color
end

child :user do
  attributes :id, :email
end
