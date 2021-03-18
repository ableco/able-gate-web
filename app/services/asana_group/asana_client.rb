require 'asana'

module AsanaGroup
  class AsanaClient < SimpleDelegator
    attr_reader :organization_id

    def initialize(access_token, organization_id)
      client = ::Asana::Client.new do |config|
        config.authentication(:access_token, access_token)
      end

      super(client)
      @organization_id = organization_id
    end

    def find_team_by_name(team_name)
      teams.find_by_organization(organization: @organization_id).find do |team|
        team.name == team_name
      end
    end

    def find_organization_by_id(organization_id)
      workspaces.find_by_id(organization_id)
    end

    def find_membership(team, member_email)
      team.users(options: { expand: ['email'] }).find do |user|
        user.email == member_email
      end
    end

    def organization
      @organization ||= find_organization_by_id(@organization_id)
    end
  end
end
