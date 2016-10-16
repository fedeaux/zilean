module ReportMetrics
  class MeanDuration < Base
    def initialize(report, results_tree)
      @report = report
      @results_tree = results_tree
      @target_days = {}

      @started_at = nil
      @finished_at = nil
      super()
    end

    def self.dependencies
      [ReportMetrics::TotalDuration] + super
    end

    def add(log_entry)
      if @report.weekdays.include? log_entry.finished_at.wday or @report.weekdays.include? log_entry.started_at.wday
        id = log_entry.activity.id

        @target_days[id] ||= []
        @target_days[id] << log_entry.started_at.strftime('%Y-%m-%d')
        @target_days[id] << log_entry.finished_at.strftime('%Y-%m-%d')
        @target_days[id].uniq!

        if @started_at.nil? or log_entry.started_at < @started_at
          @started_at = log_entry.started_at
        end

        if @finished_at.nil? or log_entry.finished_at > @finished_at
          @finished_at = log_entry.finished_at
        end
      end
    end

    def resolve
      timespan_in_days = (@finished_at.end_of_day - @started_at.beginning_of_day) / (24*60*60)
      timespan_in_weeks = timespan_in_days / 7.0

      @results_tree.leaf_first_search.each do |metric_node|
        id = metric_node.activity.id
        node_duration_in_seconds = metric_node.get_metric ReportMetrics::TotalDuration.namespace, :in_seconds, 0

        metric_node.set_metric namespace, :per_active_day,
          format_duration(node_duration_in_seconds / @target_days[id].count)

        metric_node.set_metric namespace, :on_period_per_day,
          format_duration(node_duration_in_seconds / timespan_in_days)

        metric_node.set_metric namespace, :on_period_per_week,
          format_duration(node_duration_in_seconds / timespan_in_weeks)
      end
    end
  end
end
