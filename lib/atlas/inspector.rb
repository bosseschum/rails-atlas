module Atlas
  class Inspector
    def initialize(graph)
      @graph = graph
    end

    def inspect(model_name)
      {
        outgoing: outgoing_for(model_name),
        incoming: incoming_for(model_name)
      }
    end

    private

    def outgoing_for(model_name)
      @graph[:edges].select do |edge|
        edge[:source] == model_name
      end
    end

    def incoming_for(model_name)
      @graph[:edges].select do |edge|
        edge[:target] == model_name
      end
    end
  end
end
