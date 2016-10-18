module ReportMetrics
  class ResultsTree
    def initialize(activities = [])
      @nodes = {}
      @root = treefy_activities(activities)
    end

    def roots
      @root.values
    end

    def nodes
      @nodes.values
    end

    def [](index)
      @nodes[index]
    end

    def leafs
      nodes.select { |node|
        node.is_leaf?
      }
    end

    def leaf_first_search
      unless @leaf_first_search_result
        @leaf_first_search_result = leafs
        current_index = 0

        while @leaf_first_search_result[current_index]
          if @leaf_first_search_result[current_index].parent and
              !@leaf_first_search_result.include? @leaf_first_search_result[current_index].parent

            @leaf_first_search_result << @leaf_first_search_result[current_index].parent
          end

          current_index += 1
        end
      end

      @leaf_first_search_result
    end

    def treefy_activities(activities)
      root = {}

      pending_activities = activities.dup

      while pending_activities.any?
        activity = pending_activities.shift

        if (activity.ancestors & pending_activities).any?
          pending_activities << activity

        else
          branch_to_add = root

          activity.ancestors.each do |ancestor|
            if branch_to_add[ancestor.id]
              branch_to_add = branch_to_add[ancestor.id]
            end
          end

          parent = branch_to_add == root ? nil : branch_to_add
          branch_to_add[activity.id] = ResultsTreeNode.new activity, parent
          @nodes[activity.id] = branch_to_add[activity.id]
        end
      end

      root
    end

    def to_s
      @root.values.map(&:to_s).join "\n"
    end
  end
end
