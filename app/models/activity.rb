class Activity < ApplicationRecord
  belongs_to :user
  has_many :report_activities
  has_many :reports, through: :report_activities

  has_ancestry

  validates_presence_of :name, :slug, :user, :color
  before_validation :infer_slug
  before_validation :infer_color
  before_save :update_path_names
  default_scope { order('path_names') }
  serialize :path_names

  def update_path_names
    self.path_names = path.map { |activity| activity.name }
  end

  def infer_slug
    unless self.slug
      if parent
        self.slug = [parent.slug, self.name.urlize].join ':'
      elsif self.name
        self.slug = self.name.urlize
      end
    end
  end

  def infer_color
    if !self.color
      if self.parent
        self.color = self.parent.color
      else
        self.color = 'black'
      end
    end
  end

  def path_ids
    ancestor_ids + [id]
  end

  def path
    ancestors.all + [self]
  end

  def path_names(join: nil)
    activities = super()
    return activities.join join if join
    activities
  end

  def breadcrumbs_path_names
    path_names join: ' > '
  end
end
