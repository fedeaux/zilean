class Activity < ApplicationRecord
  belongs_to :user
  has_ancestry

  validates_presence_of :name, :slug, :user, :color
end
