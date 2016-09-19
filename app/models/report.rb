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

  def log_entries
    conditions_strings = []
    conditions_values = {}

    if self.start
      conditions_strings << "started_at >= :start"
      conditions_values[:start] = self.start
    end

    if self.finish
      conditions_strings << "finished_at <= :finish"
      conditions_values[:finish] = self.finish
    end

    conditions_string = conditions_strings.join ' AND '

    activities.map { |activity|
      if conditions_strings.any?
        activity.log_entries.where(conditions_string, conditions_values)
      else
        activity.log_entries
      end
    }.flatten
  end

  def metrics=(metrics)
    super metrics.map { |metric|
      if metric.is_a? String
        'ReportMetrics::' + metric.gsub('ReportMetrics::', '')
      else
        metric
      end
    }.reject(&:nil?)
  end

  def metrics
    names = super

    names.map { |metric_name|
      metric_name.constantize
    }
  end
end
