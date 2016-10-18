module ReportMetrics
  class ResultsTreeNode
    attr_reader :children
    attr_reader :activity
    attr_reader :metrics
    attr_reader :parent

    def initialize(activity = nil, parent = nil)
      @activity = activity
      @parent = parent
      @children = {}
      @metrics = {}
    end

    def is_leaf?
      @children.empty?
    end

    def children_nodes
      @children.values
    end

    def []= (index, value)
      @children[index] = value
    end

    def [](index)
      @children[index]
    end

    def set_metric(namespace, name, value = false)
      ensure_metric_namespace namespace
      @metrics[namespace][name] = value
    end

    def get_metric(namespace, name, default_value)
      if @metrics[namespace] and @metrics[namespace][name]
        @metrics[namespace][name]
      else
        default_value
      end
    end

    def ensure_metric_namespace(namespace)
      @metrics[namespace] ||= {}
    end

    def metrics_to_s
      if @metrics.any?
        values_s = @metrics.map { |key, value|
          inner = value.map { |v_key, v|
            "#{v_key}: #{v}"
          }.join ', '

          "#{key}: (#{inner})"
        }.join "\n    "

        return "  metrics:\n    #{values_s}"
      end
    end

    def children_to_s
      if @children.any?
        values_s = @children.values.map(&:to_s).map { |child_s|
          child_s.split("\n").map { |line|
            line.gsub(/^/, '    ')
          }.join "\n"
        }.join "\n"

        return "  children:\n#{values_s}"
      end
    end

    def to_s
      [activity.name, metrics_to_s, children_to_s].reject(&:nil?).join "\n"
    end
  end
end
