module Invision
  INVISION_API_URL = 'https://projects.invisionapp.com/api/'
  class InvisionClient
    def initialize(access_id, access_token)
      cookies_header = "INVISIONAPP_SESSION_ID_V2_LIVE=#{access_id}; " \
        "INVISIONAPP_SESSION_TOKEN_V2_LIVE=#{access_token};"
      @client = RestClient::Resource.new(ABSTRACT_API_URL, headers: { "Cookies": cookies_header })
    end

    def add_member(email, project)
      JSON.parse(@client['team-invitation'].post(
        params: {
          canCreateProjectsForLead: false,
          initialProjectMembershipList: find_project(project)['id'],
          memberEmail: email,
          messageFromUser: ''
        }
      ).body)
    end

    def remove_member(email)
      member = find_member(email)
      shared_projects(member).each do |project|
        JSON.parse(@client["api/project/#{project['id']}/change-users"].post(
          params: {
            addUserIDList: '',
            id: project['id'],
            newUsersEmailMsg: '',
            removeUserIDList: (member['id']).to_s
          }
        ).body)
      end
    end

    def find_project(project_name)
      projects.find { |project| project['name'] == project_name }
    end

    def find_member(email)
      members.find { |member| member['email'] == email }
    end

    def members
      body = JSON.parse(@client['partials/desktop/team/list'].get.body)
      body['connections']['groups'][0]['teamMembers']
    end

    def projects
      body = JSON.parse(@client['partials/desktop/standard/projects'].get.body)
      body['projects']
    end

    def shared_projects(member)
      body = JSON.parse(
        @client["partials/desktop/team/detail/#{member['id']}/shared-projects"].get.body
      )
      body['projects']
    end
  end
end
