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
          target = association[:target].to_s.singularize

          edges << {
            source: model_name,
            target: target,
            relationship: association[:type],
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
