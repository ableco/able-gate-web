require 'tracker_api'

module PivotalTracker
  module Endpoints
    class Memberships < TrackerApi::Endpoints::Memberships
      attr_accessor :client

      def delete(project_id, person_id)
        client.delete("/projects/#{project_id}/memberships/#{person_id}").body
      end
    end
  end
end
