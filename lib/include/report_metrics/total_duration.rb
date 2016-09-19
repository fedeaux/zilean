module ReportMetrics
  class TotalDuration < Base
    def initialize(report)
      @report = report
      @duration = 0
    end

    def add(log_entry)
      if @report.weekdays.include? log_entry.finished_at.wday or @report.weekdays.include? log_entry.started_at.wday
        @duration += log_entry.duration
      end
    end

    def resolve
      {
        duration: {
          in_seconds: @duration,
          formatted: format_duration(@duration)
        }
      }
    end
  end
end
