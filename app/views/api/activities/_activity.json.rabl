attributes :id, :name, :slug, :color, :parent_id, :breadcrumbs_path_names

node :errors do |task|
  task.errors.messages
end

child :children => :children do
  extends 'api/activities/activity'
end
