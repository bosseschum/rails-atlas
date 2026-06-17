# frozen_string_literal: true

require 'sinatra/base'
require 'json'

module Atlas
  class Server < Sinatra::Base # rubocop:disable Style/Documentation
    set :public_folder, File.expand_path('../../public', __dir__)
    set :static, true

    class << self
      attr_accessor :project
    end

    set :views, File.expand_path('../../views', __dir__)

    get '/' do
      erb :index
    end

    get '/api/graph' do
      content_type :json
      {
        nodes: self.class.project.graph.node_data,
        edges: self.class.project.graph.edges
      }.to_json
    end

    get '/api/models' do
      content_type :json
      self.class.project.graph.nodes.to_json
    end

    get '/api/models/:name' do
      content_type :json
      self.class.project.graph
          .connections_for(params[:name])
          .to_json
    end

    get '/api/impact/:name' do
      content_type :json
      self.class.project.graph
          .reachable_from(params[:name])
          .to_json
    end

    get '/api/path/:from/:to' do
      content_type :json

      self.class.project
          .graph
          .shortest_path(params[:from], params[:to])
          .to_json
    end

    get '/api/model/:name' do
      content_type :json

      self.class.project
          .graph
          .metrics_for(params[:name])
          .to_json
    end
  end
end
