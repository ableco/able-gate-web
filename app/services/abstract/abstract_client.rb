module Abstract
  ABSTRACT_API_URL = 'https://api.goabstract.com/'
  class AbstractClient
    def initialize(access_token, organization_name)
      authorization_header = 'Bearer ' + access_token
      @client = RestClient::Resource.new(ABSTRACT_API_URL,
                                         headers: { "Authorization": authorization_header })
      @organization = find_organization_by_name(organization_name)
    end

    def find_organization_by_name(organization_name)
      organizations.find { |organization| organization['name'] == organization_name }
    end

    def organizations
      JSON.parse(@client['organizations'].get.body)['data']
    end

    def add_member(email, role)
      JSON.parse(@client['invitations'].post(
        params: {
          organizationId: @organization['id'],
          role: 'member',
          subscriptionRole: role,
          emails: [email]
        }
      ).body)
    end
  end
end
