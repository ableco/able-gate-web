module Sentry
  class Sentry
    def onboard(member:, configuration:)
      @client = SentryClient.new(ENV['SENTRY_API_TOKEN'], configuration['organization_id'])

      team = if configuration
               configuration['team']
             else
               member.project_key
             end
      if @client.find_member(member.email)
        @client.add_membership(member.email, team)
        Result.new(:success, "OK: #{member.email} was added to team #{team} in Sentry")
      else
        @client.invite_member(member.email, team)
        Result.new(:success, "OK: #{member.email} was added to the organization in Sentry")
      end
    end

    def offboard(member:, configuration:)
      @client = SentryClient.new(ENV['SENTRY_API_TOKEN'], configuration['organization_id'])

      if @client.find_member(member.email)
        @client.remove_member(member.email)
        Result.new(:success, "OK: #{member.email} was removed from the organization in Sentry")
      else
        Result.new(:warning, "Warning: #{member.email} is not a member of the organization in Sentry")
      end
    end

    def offboard_from_project(member:, configuration:)
      project = configuration['team']
      team =  @client.find_team(project)
      if team
        if @client.find_member(member.email)
          @client.remove_membership(member.email, team['slug'])
          Result.new(:success, "OK: #{member.email} was removed from the #{team['slug']} team in Sentry")
        else
          Result.new(:warning, "Warning: #{member.email} is not a member of the organization in Sentry")
        end
      else
        Result.new(:error,
                   "Error: The team #{project} doesn't have a valid Sentry team. Please verify your configuration.")
      end
    end

    def start(project:)
      create_team(project.name)
      create_project(project.name)
    end

    def check_member(member:)
      if current_member = @client.find_member(member.email)
        puts "OK: #{current_member['email']} is a member of the following Sentry teams:"
        memberships = @client.memberships(current_member['id'])
        memberships.each { |membership| puts "* #{membership}" }
      else
        puts "Warning: The member #{member.email} doesn't exists on Sentry"
      end
    end

    def check_team(team:)
      if members = @client.team_members(team.name)
        puts "OK: #{team.name} has the following team members in Sentry:"
        members.each { |member| puts "* #{member['email']} #{'(invited)' if member['pending']}" }
      else
        puts "Warning: The team #{team.name} doesn't exists on Sentry"
      end
    end

    def create_team(project_name)
      if !@client.find_team(project_name)
        @client.create_team(project_name)
        puts "OK: The team #{project_name} was created in Sentry"
      else
        puts "Warning: The team #{project_name} was already created in Sentry"
      end
    end

    def create_project(project_name)
      if !@client.find_project(project_name)
        @client.create_project(project_name)
        puts "OK: The project #{project_name} was created in Sentry"
      else
        puts "Warning: The project #{project_name} was already created in Sentry"
      end
    end

    def team_configuration(team)
      AbleGateCLI::CONFIG['projects'][team]['sentry']
    end
  end
end
