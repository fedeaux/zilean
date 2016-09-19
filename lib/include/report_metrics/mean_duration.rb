module ReportMetrics
  class MeanDuration < Base
    def initialize(report)
      @report = report
      @durations = []
    end

    def add(log_entry)
      ap log_entry

      if @report.weekdays.include? log_entry.finished_at.wday or @report.weekdays.include? log_entry.started_at.wday
        @durations << log_entry.duration
      end
    end

    def resolve
      if @durations.length > 0
        mean_duration = @durations.sum / @durations.length
      else
        mean_duration = -1
      end

      {
        mean_duration: {
          in_seconds: mean_duration,
          formatted: format_duration(mean_duration)
        }
      }
    end
  end
end
