require 'tracker_api'

module PivotalTracker
  class PivotalTrackerClient < SimpleDelegator
    def initialize(token)
      super(TrackerApi::Client.new(token: token))
    end

    def accounts(params = {})
      Endpoints::Accounts.new(self).get(params)
    end

    def projects(params = {})
      Endpoints::Projects.new(self).get(params)
    end

    def find_account_by_id(account_id)
      accounts.find do |account|
        account['id'] == account_id
      end
    end

    def find_project_by_name(project_name)
      projects.find do |project|
        project['name'].casecmp(project_name).zero?
      end
    end

    def find_membership(account_or_project, member_email)
      account_or_project.memberships.find do |membership|
        membership.person.email == member_email
      end
    end
  end
end
