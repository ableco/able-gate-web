module Abstract
  class Abstract
    def onboard(member:, configuration:)
      @client = AbstractClient.new(ENV['ABSTRACT_API_TOKEN'], configuration['organization'])

      if @client.add_member(member, 'viewer')
        Result.new(:success, "OK: #{member.email} was succesfully added to organization in Abstract.")
      else
        Result.new(:error, "Error: can't add #{member.email} to organization in Abstract.")
      end
    end

    # TODO: Implement offboarding (abstract doesn't have an endpoint to get User ID from the email)
    def offboard(member:, configuration:); end
  end
end
