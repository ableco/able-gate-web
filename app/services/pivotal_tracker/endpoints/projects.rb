require 'tracker_api'

module PivotalTracker
  module Endpoints
    class Projects < TrackerApi::Endpoints::Projects
      attr_accessor :client

      def initialize(client)
        @client = client
      end

      def get(params = {})
        data = client.paginate('/projects', params: params)

        raise TrackerApi::Errors::UnexpectedData, 'Array of projects expected' unless data.is_a? Array

        data.map do |project|
          Resources::Project.new({ client: client }.merge(project))
        end
      end
    end
  end
end
