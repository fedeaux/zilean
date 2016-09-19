require 'rails_helper'

RSpec.describe ReportMetrics::ResultsTree do
  describe '#treefy_activities' do
    let(:leaf_activities) { [
      create_or_find_activity(:activity_work_project_x),
      create_or_find_activity(:activity_work_project_dharma)
    ] }

    let(:activity_with_descendants) {
      create_or_find_activity(:activity_work_project_x)
      create_or_find_activity(:activity_work_project_dharma).parent
    }

    it 'returns a tree with only leafs for activities without a parent' do
      activities = leaf_activities + [create_or_find_activity(:activity_sleep)]

      tree = ReportMetrics::ResultsTree.new activities

      expect(tree.roots.map{ |r| r.activity.id }.sort).to eq activities.map(&:id).sort
      expect(tree.roots.map{ |r| r.children }).to eq [{}, {}, {}]
    end

    it 'returns a tree with parent activities on the root, but with inner activities found via [:direct_access]' do
      activities = [activity_with_descendants, create_or_find_activity(:activity_sleep)] + leaf_activities

      tree = ReportMetrics::ResultsTree.new activities

      expect(tree.roots.map{ |r| r.activity.id }.sort).to eq activities[0..1].map(&:id).sort
      expect(tree.nodes.map{ |n| n.activity.id }.sort).to eq activities.map(&:id).sort

      expect(tree[activity_with_descendants.id].children_nodes.map{ |n| n.activity.id }.sort).to eq leaf_activities.map(&:id).sort
    end
  end
end
