module ReportMetrics
  class ResultsTreeNode
    attr_reader :children
    attr_reader :activity

    def initialize(activity = nil, parent = nil)
      @activity = activity
      @parent = nil
      @children = {}
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
  end
end
