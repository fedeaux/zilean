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

          parent = branch_to_add == root and root or nil
          branch_to_add[activity.id] = ResultsTreeNode.new activity, parent
          @nodes[activity.id] = branch_to_add[activity.id]
        end
      end

      root
    end
  end
end
