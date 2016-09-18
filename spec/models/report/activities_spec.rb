require 'rails_helper'

RSpec.describe Report, type: :model do
  describe '#activities' do
    let(:report) { create :report }
    let(:leaf_activities) { [
      create_or_find_activity(:activity_work_project_x),
      create_or_find_activity(:activity_work_project_dharma)
    ] }

    let(:activity_with_descendants) {
      create_or_find_activity(:activity_work_project_x)
      create_or_find_activity(:activity_work_project_dharma).parent
    }

    it 'starts with no activities' do
      expect(report.activities).to be_empty
    end

    it 'can be added leaf activities' do
      report.activities = leaf_activities
      report.save
      expect(report.activities).to include(*leaf_activities)
    end

    it 'can be removed leaf activities' do
      report.activities = leaf_activities
      report.save

      report.activities = [leaf_activities.first]
      report.save

      expect(report.activities).to include(leaf_activities.first)
      expect(report.activities).not_to include(leaf_activities.last)
    end

    it 'can be added activities with descendants, adding the descendants automatically' do
      report.activities = [activity_with_descendants]
      report.save

      expected_activities = [activity_with_descendants] + activity_with_descendants.descendants
      expect(report.activities).to include(*expected_activities)
    end
  end
end
