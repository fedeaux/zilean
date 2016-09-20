require 'rails_helper'

RSpec.describe ReportMetrics::ResultsTree do
  let(:leaf_activities) { [
    create_or_find_activity(:activity_work_project_x),
    create_or_find_activity(:activity_work_project_dharma)
  ] }

  let(:activity_with_descendants) {
    create_or_find_activity(:activity_work_project_x)
    create_or_find_activity(:activity_work_project_dharma).parent
  }

  describe '#treefy_activities' do
    it 'returns a tree with only leafs for activities without a parent' do
      activities = leaf_activities + [create_or_find_activity(:activity_sleep)]

      tree = ReportMetrics::ResultsTree.new activities

      expect(tree.roots.map{ |r| r.activity.id }.sort).to eq activities.map(&:id).sort
      expect(tree.roots.map{ |r| r.children }).to eq [{}, {}, {}]
    end

    it 'returns a tree with parent activities on the root, but with inner activities found via []' do
      activity_sleep = create_or_find_activity :activity_sleep
      child_activity = leaf_activities.first
      parent_activity = activity_with_descendants

      activities = [parent_activity, activity_sleep] + leaf_activities

      tree = ReportMetrics::ResultsTree.new activities

      expect(tree[activity_sleep.id].parent).to eq nil
      expect(tree[child_activity.id].parent.activity.id).to eq parent_activity.id

      expect(tree.roots.map{ |r| r.activity.id }.sort).to eq activities[0..1].map(&:id).sort
      expect(tree.nodes.map{ |n| n.activity.id }.sort).to eq activities.map(&:id).sort

      expect(tree.nodes.map{ |n| n.activity.id }.sort).to eq activities.map(&:id).sort

      expect(tree[activity_with_descendants.id].children_nodes.map{ |n| n.activity.id }.sort).to eq leaf_activities.map(&:id).sort
    end
  end

  describe '#leaf_first_search' do
    it 'returns a list of nodes such as every child appears before its parent' do
      activities = [activity_with_descendants, create_or_find_activity(:activity_sleep)] + leaf_activities
      tree = ReportMetrics::ResultsTree.new activities
      leaf_first_search = tree.leaf_first_search
      expect(leaf_first_search.last).to eq tree[activity_with_descendants.id]
    end

    it 'returns a list of nodes such as every child appears before its parent even for huge hierarchies' do
      activities = create_activity_hierarchy.shuffle
      tree = ReportMetrics::ResultsTree.new activities
      leaf_first_search = tree.leaf_first_search

      leaf_first_search_depths = leaf_first_search.map { |node| node.activity.name.split('-').first.to_i }
      expect(leaf_first_search_depths).to eq leaf_first_search_depths.sort.reverse!
    end
  end
end
