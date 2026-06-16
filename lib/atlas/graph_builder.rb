require "json"
require "active_support/inflector"

module Atlas
  class GraphBuilder
    def initialize(scanner)
      @scanner = scanner
    end

    def build
      nodes = []
      edges = []

      @scanner.model_files.each do |file|
        model_name = File.basename(file, ".rb")
        nodes << {
          id: model_name,
          type: "model",
        }

        extractor = AssociationExtractor.new(file)

        extractor.extract.each do |association|
          association[:target].to_s.singularize

          edges << {
            source: model_name,
            target: association[:target],
            relationship: association[:type],
            association_name: association[:association_name]
          }
        end
      end

      {
        nodes: nodes.uniq,
        edges: edges,
      }
    end
  end
end
