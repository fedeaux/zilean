module ReportMetrics
  class TotalDuration < Base
    def initialize(report, results_tree)
      @results_tree = results_tree
      @report = report
      @durations = {}
      super()
    end

    def add(log_entry)
      if @report.weekdays.include? log_entry.finished_at.wday or @report.weekdays.include? log_entry.started_at.wday
        @durations[log_entry.activity.id] ||= 0
        @durations[log_entry.activity.id] += log_entry.duration
      end
    end

    def resolve
      @durations.each do |activity_id, duration_in_seconds|
        metric_node = @results_tree[activity_id]

        # Propagate to parents
        loop do
          node_duration_in_seconds = metric_node.get_metric namespace, :in_seconds, 0
          metric_node.set_metric namespace, :in_seconds, duration_in_seconds + node_duration_in_seconds

          metric_node = metric_node.parent
          break if metric_node.nil?
        end
      end

      @results_tree.nodes.each do |metric_node|
        node_duration_in_seconds = metric_node.get_metric namespace, :in_seconds, false

        if node_duration_in_seconds
          metric_node.set_metric namespace, :formatted, format_duration(node_duration_in_seconds)
        end
      end
    end
  end
end
