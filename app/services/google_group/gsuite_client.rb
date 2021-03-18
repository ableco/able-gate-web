module GoogleGroup
  class GSuiteClient < Google
    def initialize(client_id, client_secret, refresh_token)
      super(client_id, client_secret, refresh_token, nil)
    end

    def add_user(email:, first_name:, last_name:, password:, change_password_at_next_login: true)
      user = ::Google::Apis::AdminDirectoryV1::User.new(
        primary_email: email,
        name: ::Google::Apis::AdminDirectoryV1::UserName.new(
          given_name: first_name,
          family_name: last_name
        ),
        password: password,
        change_password_at_next_login: change_password_at_next_login
      )
      @client.insert_user(user)
    end

    def delete_user(email:)
      @client.delete_user email
    end
  end
end
