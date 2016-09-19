module ReportMetrics
  class FinishTime
    def initialize(report)
      @report = report
      @finish_times = []
    end

    def add(log_entry)
      if @report.weekdays.include? log_entry.finished_at.wday
        delta = log_entry.finished_at - log_entry.finished_at.beginning_of_day
        @finish_times << delta
      end
    end

    def resolve
      if @finish_times.any?
        @average = @finish_times.sum / @finish_times.length

        { finish_time_average: Time.at(@average).utc }
      else
        {}
      end
    end
  end
end
