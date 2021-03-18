require 'tracker_api'

module PivotalTracker
  module Resources
    class Account < TrackerApi::Resources::Account
      attribute :client

      def memberships(params = {})
        Endpoints::AccountMemberships.new(client).get(id, params)
      end

      def add_membership(params)
        Endpoints::AccountMemberships.new(client).add(id, params)
      end

      def delete_membership(params)
        Endpoints::AccountMemberships.new(client).delete(id, params)
      end
    end
  end
end
