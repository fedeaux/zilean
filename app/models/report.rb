class Report < ApplicationRecord
  belongs_to :user
  has_many :report_activities
  has_many :activities, through: :report_activities

  ALL_WEEKDAYS = [0, 1, 2, 3, 4, 5, 6]

  def weekdays=(value)
    if value.is_a?(Array)
      value = value.map(&:to_i).reject { |day|
        ALL_WEEKDAYS.include? day
      }.sort

      value = ALL_WEEKDAYS.dup if value.empty?
    else
      value = ALL_WEEKDAYS.dup
    end

    super(value)
  end

  def weekdays
    super.map(&:to_i)
  end

  def activities=(activities)
    super activities + activities.map(&:descendants).flatten
  end
end
