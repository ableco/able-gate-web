require 'tracker_api'

module PivotalTracker
  module Resources
    class Project < TrackerApi::Resources::Project
      attribute :client
      def delete_membership(params)
        Endpoints::Memberships.new(client).delete(id, params)
      end
    end
  end
end
