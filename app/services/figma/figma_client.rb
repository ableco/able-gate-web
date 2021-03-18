module Figma
  FIGMA_API_URL = 'https://www.figma.com/api/'
  FIGMA_ROLE_LEVEL = 100
  class FigmaClient
    def initialize(figma_user, figma_password)
      @client = RestClient::Resource.new(
        FIGMA_API_URL,
        headers: {
          "content-type": 'application/json',
          "x-csrf-bypass": 'yes'
        }
      )
      session = @client['session/login'].post(
        email: figma_user,
        password: figma_password,
        username: figma_user
      )
      @cookies = session.cookies if session
    end

    def roles(team)
      response = RestClient.get(
        FIGMA_API_URL + 'roles/team/' + team.to_s,
        cookies: @cookies,
        content_type: 'application/json',
        "x-csrf-bypass": 'yes'
      )
      JSON.parse(response.body)
    end

    def find_role_by_email(email, team)
      roles(team)['meta'].find do |role|
        role['user']['email'] == email
      end
    end

    def remove_member(email, team)
      if member = find_role_by_email(email, team)
        response = RestClient.delete(
          FIGMA_API_URL + 'roles/' + member['id'],
          cookies: @cookies,
          content_type: 'application/json',
          "x-csrf-bypass": 'yes'
        )
        true
      else
        false
      end
    end

    def invite_member(email, team)
      params = {
        emails: [email],
        resource_type: 'team',
        resource_id_or_key: team,
        level: FIGMA_ROLE_LEVEL
      }

      response = RestClient.post(
        FIGMA_API_URL + 'invites',
        params.to_json,
        cookies: @cookies,
        content_type: 'application/json',
        "x-csrf-bypass": 'yes'
      )
      invite = JSON.parse(response.body)
      return true unless invite['meta']['invites'].empty?

      false
    end
  end
end
