module PivotalTracker
  class PivotalTracker
    attr_reader :account

    def onboard(member:, configuration:)
      @client = PivotalTrackerClient.new(ENV['TRACKER_API_TOKEN'])

      if member.project
        account = @client.find_account_by_id(configuration['account'])

        if account_membership = @client.find_membership(account, member.email)
          Result.new(:warning, "Warning: #{member.email} already added to Pivotal Tracker")
        else
          account.add_membership(email: member.email)
          Result.new(:success, "OK: #{member.email} was succesfully added to Pivotal Tracker account")
        end

        project_name = configuration['project']
        add_member_to_project(member, project_name)

      end
      if member.role
        role_configuration(member.role).each do |project_name|
          add_member_to_project(member, project_name)
        end
      end
    end

    def offboard(member:, configuration:)
      @client = PivotalTrackerClient.new(ENV['TRACKER_API_TOKEN'])

      account = @client.find_account_by_id(configuration['account'])

      if account_membership = @client.find_membership(account, member.email)
        if account.delete_membership(account_membership.id)
          Result.new(:success, "OK: #{member.email} was succesfully removed from Pivotal Tracker account")
        end
      else
        Result.new(:error, "Error: Can't find member: #{member.email}")
      end
    end

    def offboard_from_project(member:, configuration:)
      project_name = configuration['project']
      account = @client.find_account_by_id(@account)
      if project = @client.find_project_by_name(project_name) && project_membership = @client.find_membership(project,
                                                                                                              member.email) && project.delete_membership(project_membership.id)
        Result.new(:success,
                   "OK: #{member.email} was succesfully removed from project #{project.name} in Pivotal Tracker")
      end
    end

    private

    def team_configuration(team)
      AbleGateCLI::CONFIG['projects'][team]['pivotal_tracker']
    end

    def role_configuration(role)
      AbleGateCLI::CONFIG['roles'][role]['pivotal_tracker']['projects']
    end

    def add_member_to_project(member, project_name)
      if project = @client.find_project_by_name(project_name)
        project_role = member.admin ? 'owner' : 'member'

        if project_membership = @client.find_membership(project, member.email)
          puts "Warning: #{member.email} already added to project #{project.name} in Pivotal Tracker"
        else
          project.add_membership(email: member.email, role: project_role)

          puts "OK: #{member.email} was succesfully added to project #{project.name} in Pivotal Tracker"
        end
      else
        puts "Error: Can't find project: #{project_name}. Please verify your configuration"
      end
    end
  end
end
