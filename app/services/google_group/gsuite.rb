require 'securerandom'

module GoogleGroup
  class GSuite
    def onboard(member:, configuration:)
      @client = GSuiteClient.new(
        ENV['GOOGLE_CLIENT_ID'],
        ENV['GOOGLE_CLIENT_SECRET'],
        ENV['GOOGLE_REFRESH_TOKEN']
      )

      handler do
        password = SecureRandom.base64(12)
        @client.add_user(
          email: member.email,
          first_name: member.first_name,
          last_name: member.last_name,
          password: password
        )
        return Result.new(:success, "OK: #{member.email} was added to G-Suite\nPassword: #{password}")
      end
    end

    def offboard(member:, configuration:)
      @client = GSuiteClient.new(
        ENV['GOOGLE_CLIENT_ID'],
        ENV['GOOGLE_CLIENT_SECRET'],
        ENV['GOOGLE_REFRESH_TOKEN']
      )

      handler do
        @client.delete_user email: member.email
        return Result.new(:success, "OK: #{member.email} removed from G-Suite")
      end
    end

    def handler
      yield
    rescue StandardError => e
      Result.new(:error, e.message)
    end
  end
end
