require "thor"
require_relative "scanner"
require_relative "association_extractor"
require_relative "graph_builder"
require "json"

module Atlas
  class CLI < Thor
    desc "scan PATH", "Scan a Rails application"

    def scan(path)
      scanner = Scanner.new(path)

      graph = GraphBuilder.new(scanner).build

      File.write(
        "atlas.json",
        JSON.pretty_generate(graph),
      )

      puts "Scan complete. Atlas graph saved to atlas.json"
    end
  end
end
