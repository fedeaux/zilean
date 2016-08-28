require 'rails_helper'

RSpec.describe Activity, type: :model do
  describe 'FactoryGirl factory' do
    it 'has valid factories' do

      work = create :activity_work
      project_x = create :activity_work_project_x
      project_dharma = create :activity_work_project_dharma

      expect(work).to be_valid
      expect(project_x).to be_valid
      expect(project_dharma).to be_valid

      expect(project_x.parent).to eq work
    end

    it 'can have an activity fetched from the database instead of creating it' do
      work_1 = create_or_find_activity :activity_work
      work_2 = create_or_find_activity :activity_work

      expect(work_1.id).to eq work_2.id
    end
  end

  describe 'validations' do
    it 'is invalid without name, slug, user or color' do
      attributes = attributes_for :activity_work_project_x

      expect(Activity.new attributes.slice(:name, :slug, :user)).to be_invalid
      expect(Activity.new attributes.slice(:name, :slug, :color)).to be_invalid
      expect(Activity.new attributes.slice(:name, :user, :color)).to be_invalid
      expect(Activity.new attributes.slice(:slug, :user, :color)).to be_invalid
    end
  end
end
