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
  end
end
