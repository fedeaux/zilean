module ReportMetrics
  class FinishTime < Base
    def initialize(report, results_tree)
      @results_tree = results_tree
      @report = report
      @finish_times = {}
      super()
    end

    def add(log_entry)
      if @report.weekdays.include? log_entry.finished_at.wday
        delta = log_entry.finished_at - log_entry.finished_at.beginning_of_day
        @finish_times[log_entry.activity.id] ||= []
        @finish_times[log_entry.activity.id] << delta
      end
    end

    def resolve
      if @finish_times.any?
        @finish_times.each do |activity_id, times|
          if times.any?
            average = times.sum / times.length
            @results_tree[activity_id].set_metric namespace, :average_in_seconds, average
            @results_tree[activity_id].set_metric namespace, :average_formatted, Time.at(average).utc.strftime('%H:%M')
          end
        end
      end
    end
  end
end
