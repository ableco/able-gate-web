require 'tracker_api'

module PivotalTracker
  module Endpoints
    class AccountMemberships
      attr_accessor :client

      def initialize(client)
        @client = client
      end

      def get(account_id, params = {})
        response = client.paginate("/accounts/#{account_id}/memberships", params: params)

        raise TrackerApi::Errors::UnexpectedData, 'Array of memberships expected' unless response.is_a? Array

        response.map do |membership|
          membership_with_account_id = { account_id: account_id }.merge(membership)

          Resources::AccountMembership.new(membership_with_account_id)
        end
      end

      def add(account_id, params = {})
        response = client.post("/accounts/#{account_id}/memberships", params: params).body

        response_with_account_id = { account_id: account_id }.merge(response)

        Resources::AccountMembership.new(response_with_account_id)
      end

      def delete(account_id, person_id)
        client.delete("/accounts/#{account_id}/memberships/#{person_id}").body
      end
    end
  end
end
