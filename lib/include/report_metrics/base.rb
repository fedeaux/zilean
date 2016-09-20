module ReportMetrics
  class Base
    attr_reader :namespace

    def initialize
      @namespace = self.class.namespace
    end

    def self.namespace
      self.name
    end

    def self.dependencies
      [self]
    end

    def format_duration(duration_in_seconds)
      parts = duration_parts duration_in_seconds
      string_parts = []

      {years: 'Y', months: 'M', weeks: 'w', days: 'd', hours: 'h', minutes: 'min' }.each { |key, unit|
        if parts[key] and parts[key] > 0
          string_parts << "#{parts[key]}#{unit}"
        else
          string_parts << nil
        end
      }

      selected_string_parts = []

      string_parts.each do |part|
        if part
          selected_string_parts << part
        elsif selected_string_parts.length > 0
          break
        end

        break if selected_string_parts.length == 3
      end

      selected_string_parts.length > 0 ? selected_string_parts.join('') : '0'
    end

    def duration_parts(duration_in_seconds)
      duration_in_seconds = duration_in_seconds.to_i
      duration = {}
      duration[:seconds] = duration_in_seconds % 60

      if duration_in_seconds > 59
        duration_in_minutes = duration_in_seconds / 60
        duration[:minutes] = duration_in_minutes % 60

        if duration_in_minutes > 60
          duration_in_hours = duration_in_minutes / 60
          duration[:hours] = duration_in_hours % 24

          if duration_in_hours >= 24
            duration_in_days = duration_in_hours / 24
            duration[:days] = duration_in_days % 7

            if duration_in_days >= 30
              duration_in_months = duration_in_days / 30
              duration[:months] = duration_in_months % 12

              if duration_in_months >= 12
                duration[:years] = duration_in_months / 12
              end
            end

            remaining_duration_in_days = duration_in_days % 30

            if remaining_duration_in_days >= 7
              duration_in_weeks = remaining_duration_in_days / 7
              duration[:weeks] = duration_in_weeks
            end

            remaining_duration_in_days = remaining_duration_in_days % 7
            duration[:days] = remaining_duration_in_days
          end
        end
      end

      duration
    end
  end
end
