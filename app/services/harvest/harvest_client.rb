require 'harvesting'

module Harvest
  class HarvestClient < SimpleDelegator
    attr_reader :account_id

    def initialize(access_token, account_id)
      client = ::Harvesting::Client.new(access_token: access_token, account_id: account_id)
      super(client)
      @account_id = account_id
    end

    def create_user(member_email, member_first_name, member_last_name)
      Harvesting::Models::User.new(
        {
          'first_name' => member_first_name,
          'last_name' => member_last_name,
          'email' => member_email
        },
        client: self
      ).save
    end

    def create_user_assignment(user, project)
      Harvesting::Models::ProjectUserAssignment.new(
        {
          'project' => {
            'id' => project.id.to_s
          },
          'user' => {
            'id' => user.id.to_s
          }
        },
        client: self
      ).save
    end

    def delete_user(member_id)
      Harvesting::Models::User.delete(
        member_id,
        client: self
      )
    end

    def find_project_by_name(project_name)
      projects.find do |project|
        project.name == project_name
      end
    end

    def find_user_by_email(member_email)
      users.find do |user|
        user.email == member_email
      end
    end

    def find_account_by_id(account_id)
      workspaces.find_by_id(account_id)
    end

    def find_user_assignment(project, user)
      project.user_assignments.find do |assignment|
        assignment.user.id == user.id
      end
    end

    def account
      @account ||= find_account_by_id(@account_id)
    end
  end
end
