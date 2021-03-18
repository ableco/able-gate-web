module Harvest
  class Harvest
    def onboard(member:, configuration:)
      @client = HarvestClient.new(ENV['HARVEST_API_TOKEN'], configuration['account_id'])

      if project = find_project(configuration['project'])
        if harvest_user = find_user(member.email)
          if @client.find_user_assignment(project, harvest_user)
            Result.new(:warning, "Warning: #{member.email} already added to project #{project.name} in Harvest")
          else
            @client.create_user_assignment(harvest_user, project)
            Result.new(:success,
                       "OK: #{member.email} was succesfully added to project #{project.name} in Harvest")
          end
        else
          user = @client.create_user(member.email, member.first_name, member.last_name)
          return Result.new(:success, "OK: #{member.email} was succesfully added to Harvest account")
          @client.create_user_assignment(user, project)
          Result.new(:success, "OK: #{member.email} was succesfully added to project #{project.name} in Harvest")
        end
      else
        Result.new(:error,
                   "Error: Can't find team: #{configuration['project']}. Please verify your configuration")
      end
    end

    def offboard(member:, configuration:)
      @client = HarvestClient.new(ENV['HARVEST_API_TOKEN'], configuration['account_id'])
      if user = find_user(member.email)
        return Result.new(:success, "OK: #{member.email} was succesfully removed from Harvest") if user.delete
      else
        Result.new(:error,
                   "Error: Can't find user: #{member.email} in Harvest account. Please verify your configuration")
      end
    end

    private

    def find_project(project_name)
      @client.find_project_by_name(project_name)
    end

    def find_user(member_email)
      @client.find_user_by_email(member_email)
    end

    def find_account
      @client.account
    end
  end
end
