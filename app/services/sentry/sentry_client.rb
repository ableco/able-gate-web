module Sentry
  SENTRY_API_URL = 'https://sentry.io/api/0/'
  class SentryClient
    def initialize(access_token, organization)
      authorization_header = "Bearer #{access_token}"
      @organization = organization
      @client = RestClient::Resource.new(SENTRY_API_URL,
                                         headers: {
                                           "Authorization": authorization_header,
                                           "content-type": 'application/json'
                                         })
    end

    def find_team(team_name)
      teams.find { |team| team['slug'] == team_name }
    end

    def create_team(team_name)
      JSON.parse(@client["organizations/#{@organization}/teams/"].post(
        slug: team_name
      ).body)
    end

    def find_project(project_name)
      team_name = project_name
      projects(team_name).find { |project| project['slug'] == project_name }
    end

    def find_member(member_email)
      members.find { |member| member['email'] == member_email }
    end

    def create_project(project_name)
      team_name = project_name

      JSON.parse(@client["teams/#{@organization}/#{team_name}/projects/"].post(
        name: project_name
      ).body)
    end

    def invite_member(email, team_name)
      JSON.parse(@client["organizations/#{@organization}/members/"].post(
        email: email,
        teams: team_name,
        role: 'member'
      ).body)
    end

    def remove_member(email)
      member = find_member(email)
      @client["organizations/#{@organization}/members/#{member['id']}/"].delete
    end

    def add_membership(email, team_name)
      member = find_member(email)
      teams = memberships(member['id'])
      teams |= [team_name]
      update_membership(member['id'], teams)
    end

    def remove_membership(email, team_name)
      member = find_member(email)
      teams = memberships(member['id'])
      teams.delete(team_name)
      update_membership(member['id'], teams)
    end

    def update_membership(member_id, teams)
      params = {
        teams: teams
      }
      JSON.parse(@client["organizations/#{@organization}/members/#{member_id}/"].put(
        params.to_json
      ).body)
    end

    def team_members(team_name)
      JSON.parse(@client["teams/#{@organization}/#{team_name}/members/"].get.body)
    end

    def teams
      JSON.parse(@client["organizations/#{@organization}/teams/"].get.body)
    end

    def members
      JSON.parse(@client["organizations/#{@organization}/members/"].get.body)
    end

    def projects(team_name)
      JSON.parse(@client["teams/#{@organization}/#{team_name}/projects/"].get.body)
    end

    def memberships(member_id)
      JSON.parse(
        @client["organizations/#{@organization}/members/#{member_id}/"].get.body
      )['teams']
    end
  end
end
