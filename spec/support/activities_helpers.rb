module ActivityHelpers
  def create_activity_hierarchy(depth: 4, children_per_activity: [1, 2, 3], root_activities: 2)
    current_depth = 0
    activities_on_depth = [[]]

    root_activities.times do |i|
      activities_on_depth[0] << create(:activity, name: "#{current_depth}-#{i}")
    end

    current_depth += 1
    while current_depth < depth
      activities_on_depth[current_depth] ||= []

      activities_on_depth[current_depth - 1].each_with_index do |parent_activity, i|
        children_per_activity[i % children_per_activity.length].times do
          activities_on_depth[current_depth] << create(:activity, name: "#{current_depth}-#{i} < #{parent_activity.name}",
            parent: parent_activity)
        end
      end

      current_depth += 1
    end

    activities_on_depth.flatten
  end
end

RSpec.configure do |config|
  config.include ActivityHelpers
end
