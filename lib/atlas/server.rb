# frozen_string_literal: true

require 'sinatra/base'
require 'json'

module Atlas
  class Server < Sinatra::Base # rubocop:disable Style/Documentation
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
        "nodes": [
          { id: 'member', type: 'model' },
          { id: 'organization', type: 'model' }
        ],
        "edges": [
          {
            source: 'member',
            target: 'organization',
            relationship: 'has_many',
            association_name: 'organizations'
          }
        ]
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
  end
end
