module Atlas
  class Neighbors
    def initialize(graph)
      @graph = graph
    end

    def find(model_name)
      connected = []

      @graph[:edges].each do |edge|
        if edge[:source] == model_name
          connected << {
            model: edge[:target],
            relationship: edge[:relationship],
            association_name: edge[:association_name],
            direction: :outgoing
          }
        end

        if edge[:target] == model_name
          connected << {
            model: edge[:source],
            relationship: edge[:relationship],
            association_name: edge[:association_name],
            direction: :incoming
          }
        end
      end

      connected.uniq { |c| c[:model] }
    end
  end
end
