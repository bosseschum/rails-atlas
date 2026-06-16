require "thor"
require "json"
require_relative "project"
require_relative "scanner"
require_relative "association_extractor"
require_relative "graph_builder"
require_relative "stats"
require_relative "graph_exporter"
require_relative "inspector"
require_relative "path_finder"
require_relative "neighbors"


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
        puts "#{edge[:relationship]} #{edge[:association_name]}"
      end

      puts
      puts "Incoming Associations:"
      puts "----------------------"

      result[:incoming].each do |edge|
        puts "#{edge[:source]} #{edge[:relationship]} #{edge[:association_name]}"
      end
    end

    desc "path PATH START END", "Find path between two models"

    def path(path, start, end_node)
      scanner = Scanner.new(path)
      graph = GraphBuilder.new(scanner).build
      result = PathFinder.new(graph).find_path(start, end_node)

      if result.nil?
        puts "No path found"
        return
      end

      puts
      result.each_with_index do |node, index|
        puts node

        puts " ↓" unless index == result.length - 1
      end
    end

    desc "neighbors MODEL", "Show directly connected neighbors"

    def neighbors(path, model)
      scanner = Scanner.new(path)
      graph = GraphBuilder.new(scanner).build
      neighbors = Neighbors.new(graph).find(model)

      puts
      puts "Model: #{model}"
      puts
      puts "Directly Connected Models"
      puts "-------------------------"

      neighbors.each do |neighbor|
        arrow = neighbor[:direction] == :outgoing ? "→" : "←"
        puts "#{arrow} #{neighbor[:relationship]} #{neighbor[:model]}"
      end
    end
  end
end
