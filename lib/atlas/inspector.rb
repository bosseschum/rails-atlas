# frozen_string_literal: true

module Atlas
  class Inspector # rubocop:disable Style/Documentation
    def initialize(graph)
      @graph = graph
    end

    def inspect(model_name)
      {
        outgoing: @graph.outgoing_connections(model_name),
        incoming: @graph.incoming_connections(model_name)
      }
    end
  end
end
