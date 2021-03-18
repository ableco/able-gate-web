module GoogleGroup
  class Google
    ROLE_OWNER = 'OWNER'
    ROLE_MEMBER = 'MEMBER'

    def onboard(member:, configuration:)
      @client = GoogleClient.new(
        ENV['GOOGLE_CLIENT_ID'],
        ENV['GOOGLE_CLIENT_SECRET'],
        ENV['GOOGLE_REFRESH_TOKEN'],
        configuration['google_domain']
      )

      @configuration = configuration

      team_configuration = @configuration
      if member.department
        if department_groups = department_configuration(member.department_key)
          department_groups.each do |department_group|
            if group = find_group(team_configuration[department_group])
              onboard_to_group(group, member.email)
            else
              return Result.new(:error,
                                "Error: Can't find group: #{department_group}. Please verify your configuration")
            end
          end
        else
          return Result.new(:error,
                            "Error: Can't find #{member.department} department in the config file. Please verify your configuration")
        end
      end

      if member.location
        if location_groups = location_configuration(member.location_key)
          location_groups.each do |location_group|
            if group = find_group(team_configuration[location_group])
              onboard_to_group(group, member.email)
            else
              return Result.new(:error, "Error: Can't find group: #{location_group}. Please verify your configuration")
            end
          end
        else
          return Result.new(:error,
                            "Error: Can't find #{member.location} location in the config file. Please verify your configuration")
        end
      end

      if member.project
        onboard_to_project(member.project_key, member.email)
      else
        return Result.new(:error,
                          "Error: Can't find #{member.team} team in the config file. Please verify your configuration")
      end

      if standard_group = find_group(team_configuration['standard_team'])
        onboard_to_group(standard_group, member.email)
      else
        return Result.new(:error,
                          "Error: Can't find group: #{team_configuration['standard_team']}. Please verify your configuration")
      end

      if member.admin
        if admin_group = find_group(team_configuration['admin_team'])
          onboard_to_group(admin_group, member.email, ROLE_OWNER)
        else
          Result.new(:error,
                     "Error: Can't find group: #{team_configuration['admin_team']}. Please verify your configuration")
        end
      end
    end

    def offboard(member:, configuration:)
      @client = GoogleClient.new(
        ENV['GOOGLE_CLIENT_ID'],
        ENV['GOOGLE_CLIENT_SECRET'],
        ENV['GOOGLE_REFRESH_TOKEN'],
        configuration['google_domain']
      )

      @client.groups.each do |group|
        if @client.has_group_membership(group.id, member.email)
          if @client.remove_group_membership(group.id, member.email)
            return Result.new(:success, "OK: #{member.email} was succesfully removed from group #{group.name}")
          else
            return Result.new(:error, "Error: Can't remove #{member.email} from group #{group.name}")
          end
        end
      end

      Result.new(:warning, "Error: There are not groups. Can't remove #{member.email}")
    end

    def offboard_from_project(member:, project:)
      configuration = team_configuration(project)
      configuration.values.each do |group_name|
        next unless group = find_group(group_name)

        if @client.has_group_membership(group.id, member.email)
          if @client.remove_group_membership(group.id, member.email)
            puts "OK: #{member.email} was succesfully removed from group #{group.name}"
          else
            puts "Error: Can't remove #{member.email} from group #{group.name}"
          end
        end
      end
    end

    def start(project:)
      if !@client.find_calendar_by_name(project.name)
        @client.create_calendar(project.name)
        puts "OK: The calendar #{project.name} was created in Google Calendar"
      else
        puts "Warning: The calendar #{project.name} was already created in Google Calendar"
      end

      if !@client.find_project_by_name(project.name)
        @client.create_project(project.name)
        puts "OK: The project #{project.name} was created in Google"
      else
        puts "Warning: The project #{project.name} was already created in Google"
      end

      teams = team_configuration(project.name).slice('standard_team', 'admin_team')
      teams.each_value do |group_email|
        if group = find_group(group_email)
          puts "Warning: The group #{group.name} already existed in Google Groups"
        elsif @client.create_group(group_email)
          puts "OK: The group #{group_email} was created in Google Groups"
        end
      end
    end

    def check_member(member:)
      puts "OK: #{member.email} is a member of the following Google Groups:"
      groups = @client.groups
      groups.each do |group|
        puts "* #{group.name}" if @client.has_group_membership(group.id, member.email)
      end
    end

    def check_team(team:)
      group_names = team_configuration(team.name).slice('standard_team', 'admin_team')
      group_names.each_value do |group_name|
        group = @client.find_group_by_name(group_name)
        puts "OK: #{group.email} has the following members in Google Groups:"
        members = @client.list_members(group.id, max_results: Clients::MAX_RESULTS)
        next if members.members.nil?

        members.members.any? do |member|
          puts "* #{member.email}"
        end
      end
    end

    def onboard_to_group(group, email, role = ROLE_MEMBER)
      if @client.has_group_membership(group.id, email)
        Result.new(:warning, "Warning: #{email} already added to group #{group.name} in Google")
      elsif @client.add_group_membership(group.id, email, role)
        Result.new(:success, "OK: #{email} was succesfully added to group #{group.name}")
      else
        Result.new(:error, "Error: Can't add #{email} to group #{group.name}")
      end
    end

    def onboard_to_project(project, email)
      if google_project = find_project(project)
        if !@client.find_editor_in_project(google_project.project_id, email)
          if @client.add_project_membership(google_project.project_id, email)
            Result.new(:success, "OK: #{email} was successfully added to project #{project}")
          else
            Result.new(:error, "Error: Can't add #{email} to group #{project}")
          end
        else
          Result.new(:warning, "Warning: #{email} already added to the #{project} in Google")
        end
      else
        Result.new(:error, "Error: Couldn't find #{project} project in Google")
      end
    end

    def find_project(project_name)
      @client.find_project_by_name(project_name)
    end

    def find_group(group_name)
      @client.find_group_by_name(group_name)
    end

    def onboard_to_group(group, email, role = ROLE_MEMBER)
      if @client.has_group_membership(group.id, email)
        Result.new(:warning, "Warning: #{email} already added to group #{group.name} in Google")
      elsif @client.add_group_membership(group.id, email, role)
        Result.new(:success, "OK: #{email} was succesfully added to group #{group.name}")
      else
        Result.new(:error, "Error: Can't add #{email} to group #{group.name}")
      end
    end

    def team_configuration(team)
      AbleGateCLI::CONFIG['projects'][team]['google']
    end

    def department_configuration(department)
      @configuration['departments'][department]['teams']
    end

    def location_configuration(location)
      @configuration['locations'][location]['teams']
    end
  end
end
