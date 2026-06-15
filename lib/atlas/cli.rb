require "thor"
require "json"
require_relative "scanner"
require_relative "association_extractor"
require_relative "graph_builder"
require_relative "stats"
require_relative "graph_exporter"
require_relative "inspector"

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

    desc "graph PATH", "Generate graph files"

    def graph(path)
      scanner = Scanner.new(path)
      graph = GraphBuilder.new(scanner).build
      GraphExporter.new(graph).export_dot

      puts "Generate atlas.dot"
    end

    desc "model PATH MODEL", "Inspect a model"

    def model(path, model)
      scanner = Scanner.new(path)
      graph = GraphBuilder.new(scanner).build
      result = Inspector.new(graph).inspect(model)

      puts
      puts "Model: #{model}"
      puts

      puts "Outgoing Associations:"
      puts "----------------------"

      result[:outgoing].each do |edge|
        puts "#{edge[:relationship]} -> #{edge[:target]}"
      end

      puts
      puts "Incoming Associations:"
      puts "----------------------"

      result[:incoming].each do |edge|
        puts "#{edge[:source]} #{edge[:relationship]} #{edge[:target]}"
      end
    end
  end
end
