module Atlas
  class Stats
    def initialize(graph)
      @graph = graph
    end

    def print
      puts
      puts "Atlas Statistics"
      puts "----------------"
      puts

      puts "Models: #{@graph[:nodes].count}"
      puts "Associations: #{@graph[:edges].count}"

      puts
      puts "Most Connected Models:"
      puts "----------------"
      puts

      connection_counts.each do |model, count|
        puts "#{model}: #{count}"
      end

      puts
      puts "Association Types:"
      puts "----------------"
      puts

      association_types.each do |type, count|
        puts "#{type}: #{count}"
      end

      puts
      puts "Architecture Hotspots:"
      puts "----------------"
      puts

      hotspots.each do |model|
        puts model
      end
    end

    private

    def connection_counts
      counts = Hash.new(0)

      @graph[:edges].each do |edge|
        counts[edge[:source]] += 1
        counts[edge[:target]] += 1
      end

      counts.sort_by { |_, count| -count }.first(10)
    end

    def association_types
      @graph[:edges]
      .group_by { |edge| edge[:relationship]}
      .transform_values(&:count)
    end

    def hotspots
      connection_counts.first(5).map(&:first)
    end
  end
end
