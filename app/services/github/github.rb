module Github
  class Github
    attr_reader :organization

    def onboard(member:, configuration:)
      @client = GithubClient.new(ENV['GITHUB_API_TOKEN'], configuration['github_org'])

      teams = []
      teams << find_team(configuration['github_main_team'])
      if standard_team = find_team(configuration['standard_team'])
        teams << standard_team if standard_team

        # should be a boolean value not string
        if member.admin
          admin_team = find_team(configuration['admin_team'])
          teams << admin_team if admin_team
        end

        teams.each do |team|
          if @client.has_team_membership(team.id, member.github)
            return Result.new(:warning, "Warning: #{member.github} is already member of team #{team.name}")
          elsif @client.add_team_membership(team.id, member.github)
            return Result.new(:success, "OK: #{member.github} was succesfully added to organization #{team.name}")
          else
            return Result.new(:error, "Error: Can't add #{member.github} to organization #{team.name}")
          end
        end
      else
        Result.new(:error,
                   "Error: Can't find team: #{configuration['standard_team']}. Please verify your configuration")
      end
    end

    def offboard(member:, configuration:)
      organization = configuration['github_org']
      @client = GithubClient.new(ENV['GITHUB_API_TOKEN'], organization)

      if @client.remove_organization_member(organization, member.github)
        Result.new(:success, "OK: #{member.github} was succesfully removed from organization #{organization}")
      else
        Result.new(:error, "Error: Can't remove #{member.github} from organization #{organization}")
      end
    end

    def start(project:)
      if project.github
        create_teams(project)
        create_repo(project.name)
      else
        puts "Error: The team #{project.name} doesn't have a valid Github Team configuration. Please verify your configuration."
      end
    end

    def check_member(member:)
      if @client.member_belongs_to_org?(member.github)
        teams = @client.find_teams_by_member(member.github)
        if teams.empty?
          puts "Warning: #{member.github} is not a member of any GitHub team"
        else
          puts "OK: #{member.github} is a member of the following GitHub teams:"
          teams.each do |team|
            puts "* #{team[:slug]}"
          end
        end
      else
        puts "Error: #{member.github} is not a member of our GitHub organization"
      end
    end

    def check_team(team:)
      team_names = team.github.values ||  []

      if team_names.empty?
        puts "Warning:  doesn't have any Github team associated"
      else
        team_names.each do |team|
          if @client.team_belongs_to_org?(team)
            members = @client.find_members_by_team(team)
            if members.empty?
              puts "Warning: #{team} team has no members in Github"
            else
              puts "OK: #{team} has the following team members in GitHub:"
              members.each do |member|
                puts "* #{member[:login]}"
              end
            end
          else
            puts "Error: #{team} is not a team of our GitHub organization"
          end
        end
      end
    end

    def offboard_from_project(member:, configuration:)
      project = configuration['team']
      teams = team_configuration(project).slice('standard_team', 'admin_team')
      teams.each_value do |team_name|
        team = find_team(team_name)
        next unless @client.has_team_membership(team.id,
                                                member.github) && @client.remove_team_membership(team.id,
                                                                                                 member.github)

        Result.new(:success, "OK: #{member.github} was succesfully removed from team #{team.name}")
      end
    end

    def create_teams(project)
      if project.github.key?('standard_team') && project.github.key?('admin_team')
        project.github.each do |_, team_name|
          if !find_team(team_name)
            begin
              team = @client.create_team_in_organization(team_name)
              @client.remove_team_membership(team.id, @client.user.login)
              puts "OK: The team #{team_name} was created in Github"
            rescue Exception => e
              puts "Error: Couldn't create the team in Github, please contact DevOps Team."
              puts e.message
            end
          else
            puts "Warning: The team #{team_name} is not available in the GitHub Organization. Please verify your configuration."
          end
        end
      else
        puts "Error: The team #{project.name} doesn't have a valid <standard/admin> Team configuration. Please verify your configuration."
      end
    end

    def create_repo(repository_name)
      if !@client.find_repository(repository_name)
        begin
          @client.create_repository(repository_name)
          puts "OK: The repository #{repository_name} was created in Github"
        rescue Exception => e
          puts "Error: Couldn't create the repository in Github, please contact DevOps Team."
          puts e.message
        end
      else
        puts "Warning: The repository #{repository_name} already exists in GitHub."
      end
    end

    private

    def team_configuration(team)
      AbleGateCLI::CONFIG['projects'][team]['github']
    end

    def find_team(team_name)
      @client.find_team_by_name(team_name)
    end
  end
end
