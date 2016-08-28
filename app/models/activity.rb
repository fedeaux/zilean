class Activity < ApplicationRecord
  belongs_to :user
  has_ancestry

  validates_presence_of :name, :slug, :user, :color
  before_validation :infer_slug
  before_validation :infer_color

  def infer_slug
    unless self.slug
      if parent
        self.slug = [parent.slug, self.name.urlize].join ':'
      else
        self.slug = self.name.urlize.join ':'
      end
    end
  end

  def infer_color
    if !self.color and self.parent
      self.color = self.parent.color
    end
  end
end
