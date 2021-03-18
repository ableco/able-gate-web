module AsanaGroup
  class Asana
    def onboard(member:, configuration:)
      @client = AsanaClient.new(ENV['ASANA_API_TOKEN'], configuration['organization_id'])

      if organization = find_organization
        if team = find_team(configuration['team'])
          if @client.find_membership(team, member.email)
            Result.new(:warning, "Warning: #{member.email} already added to team #{team.name} in Asana")
          else
            organization.add_user(user: member.email)
            begin
              team.add_user(user: member.email)
              Result.new(:success, "OK: #{member.email} was succesfully added to team #{team.name}")
            rescue Exception => e
              if e.message.start_with?('Team is full')
                Result.new(:error,
                           "Error: #{team.name} is full. Please contact DevOps team in order to solve this issue.")
              else
                Result.new(:error,
                           "Error: #{e.message}. Please contact DevOps team in order to solve this issue.")
              end
            end
          end
        else
          Result.new(:error,
                     "Error: Can't find team: #{configuration['team']}. Please verify your configuration")
        end
      else
        Result.new(:error,
                   "Error: Can't find organization with ID #{@client.organization_id}. Please verify your configuration")
      end
    end

    def offboard(member:, configuration:)
      @client = AsanaClient.new(ENV['ASANA_API_TOKEN'], configuration['organization_id'])
      if organization = find_organization
        if team = find_team(configuration['team'])
          if @client.find_membership(team, member.email)
            Result.new(:error, "Error: #{member.email} doesn't exist in team #{team.name} in Asana")
          else
            team.remove_user(user: member.email)
            organization.remove_user(user: member.email)

            Result.new(:success, "OK: #{member.email} was succesfully removed from team #{team.name}")
          end
        else
          Result.new(:error, "Error: Can't find team: #{member.team}. Please verify your configuration")
        end
      else
        Result.new(:error,
                   "Error: Can't find organization with ID #{@client.organization_id}. Please verify your configuration")
      end
    end

    private

    def find_team(team_name)
      @client.find_team_by_name(team_name)
    end

    def find_organization
      @client.organization
    end
  end
end
