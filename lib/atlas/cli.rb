require "thor"
require "json"
require_relative "scanner"
require_relative "association_extractor"
require_relative "graph_builder"
require_relative "stats"

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

    desc "stats PATH", "Show graph statistics"

    def stats(path)
      scanner = Scanner.new(path)

      graph = GraphBuilder.new(scanner).build

      Stats.new(graph).print
    end
  end
end
