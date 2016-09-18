require 'rails_helper'

RSpec.describe Report, type: :model do
  it 'has a valid factory' do
    expect(create :report).to be_valid
  end

  it 'makes weekdays default to [0, 1, 2, 3, 4, 5, 6] (all)' do
    expect(create(:report, weekdays: nil).weekdays).to eq [0, 1, 2, 3, 4, 5, 6]
  end
end
