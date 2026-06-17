# frozen_string_literal: true

require 'active_support/inflector'

module Atlas
  class Scanner
    def initialize(path)
      @path = path
    end

    def model_files
      Dir.glob(File.join(models_root, '**/*.rb')).reject { |file| concern?(file) }
    end

    def models
      model_files.map { |file| model_name_for(file) }
    end

    # Derives the fully-qualified, namespaced class name from a file's path,
    # the same way Rails/Zeitwerk does: app/models/treasurer/request.rb -> "Treasurer::Request"
    def model_name_for(file)
      relative_path(file).delete_suffix('.rb').camelize
    end

    private

    def models_root
      File.join(@path, 'app/models')
    end

    def relative_path(file)
      file.delete_prefix("#{models_root}/")
    end

    # app/models/concerns is a non-namespaced autoload path in Rails (files there
    # define top-level modules, not models) - exclude it so concerns don't show
    # up as fake model nodes.
    def concern?(file)
      relative_path(file).split('/').first == 'concerns'
    end
  end
end
