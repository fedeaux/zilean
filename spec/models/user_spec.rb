require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'FactoryGirl factory' do
    it 'has a valid factory' do
      expect(create :user_ray).to be_valid
    end

    it 'can have an user fetched from the database instead of creating it raising active-record errors' do
      expect(create_or_find_user :user_ray).to be_valid
      expect(create_or_find_user :user_ray).to be_valid
    end
  end
end
