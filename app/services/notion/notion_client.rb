module Notion
  NOTION_API_URL = 'https://www.notion.so/api/v3/'
  class NotionClient
    attr_reader :space_id, :access_token

    def initialize(access_token, space_id)
      @access_token = access_token
      @space_id = space_id
    end

    def find_member(email)
      params = { email: email }
      api_response = api_request('findUser', params)
      return nil if api_response == {}

      api_response['value']['value']['id']
    end

    def create_member(email)
      params = { email: email }
      return false if api_request('createEmailUser', params) != {}
    end

    def add_member(email)
      member_id = find_member(email)
      set_permission(member_id, 'read_and_write')
    end

    def remove_member(email)
      member_id = find_member(email)
      set_permission(member_id, 'none')
    end

    def set_permission(member_id, role)
      request_id = SecureRandom.uuid
      params = {
        "requestId": request_id,
        "transactions": [
          {
            "id": request_id,
            "operations": [
              {
                "table": 'space',
                "id": @space_id,
                "command": 'setPermissionItem',
                "path": ['permissions'],
                "args": {
                  "type": 'user_permission',
                  "user_id": member_id,
                  "role": role
                }
              },
              {
                "table": 'space',
                "id": @space_id,
                "command": 'set',
                "path": ['last_edited_time'],
                "args": Time.now.to_i
              }
            ]
          }
        ]
      }
      api_request('submitTransaction', params)
    end

    def api_request(function, params)
      url = NOTION_API_URL + function
      response = RestClient.post(
        url,
        params.to_json,
        cookies: { token_v2: @access_token },
        content_type: 'application/json'
      )
      JSON.parse(response.body)
    end
  end
end
