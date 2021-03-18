require 'tracker_api'

module PivotalTracker
  module Endpoints
    class Accounts
      attr_accessor :client

      def initialize(client)
        @client = client
      end

      def get(params = {})
        response = client.paginate('/accounts', params: params)

        raise TrackerApi::Errors::UnexpectedData, 'Array of accounts expected' unless response.is_a? Array

        response.map do |account|
          Resources::Account.new({ client: client }.merge(account))
        end
      end
    end
  end
end
