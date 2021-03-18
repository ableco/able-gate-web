module Heroku
  class Heroku
    def initialize
      @client = HerokuClient.new(ENV['HEROKU_API_TOKEN'])
    end

    def onboard(member:, configuration:)
      team_role = member.admin ? 'admin' : 'member'
      if team = @client.find_team_by_name(configuration['team'])
        if @client.find_membership(team, member.email)
          Result.new(:warning, "Warning: #{member.email} already added to #{team['name']} in Heroku")
        elsif @client.team_invitation.create(team['id'], 'email': member.email, 'role': team_role)
          Result.new(:success, "#{member.email} was succesfully invited to team #{team['name']}")
        else
          Result.new(:error, "Error: Can't invite #{member.email} to team #{team['name']}")
        end
      else
        Result.new(:error,
                   "Error: Can't find team with name #{configuration['team']}. Please verify configuration")
      end
    end

    def offboard(member:, configuration:)
      member_teams = @client.find_teams_by_member(member.email)

      if member_teams.any?
        member_teams.each do |team|
          if @client.team_member.delete(team['id'], member.email)
            return Result.new(:success, "#{member.email} was succesfully removed from team #{team['name']}")
          else
            return Result.new(:error, "Error: Can't remove #{member.email} from team #{team['name']}")
          end
        end
      else
        Result.new(:warning, "Warning: #{member.email} is not member of any group in Heroku")
      end
    end

    def offboard_from_project(member:, configuration:)
      if team = @client.find_team_by_name(configuration['team']) && @client.find_membership(team, member.email)
        if @client.team_member.delete(team['id'], member.email)
          puts "OK: #{member.email} was succesfully removed from team #{team['name']}"
        else
          puts "Error: Can't remove #{member.email} from team #{team['name']}"
        end
      end
    end

    def start(project:)
      if project.heroku && project.heroku['team']
        configuration = project.heroku['team']
        create_heroku_team(project)
      else
        puts "Error: The team #{project.name} doesn't have a valid Heroku Team configuration. Please verify your configuration."
      end
    end

    def check_member(member:)
      member_teams = @client.find_teams_by_member(member.email)
      if member_teams.any?
        puts "OK: #{member.email} is a member of the following Heroku teams:"
        member_teams.each do |team|
          puts "* #{team['name']}"
        end
        teams = @client.team.list
        teams.each do |team|
          invites = @client.team_invitation.list(team['name'])
          invites.each do |invite|
            puts "* #{team['name']} (pending)" if invite['user']['email'] == member.email
          end
        end
      else
        puts "OK: #{member.email} is a not a member of any Heroku team"
      end
    end

    def check_team(team:)
      puts "OK: #{team.heroku['team']} has the following team members in Heroku:"
      begin
        members = @client.team_member.list(team.heroku['team'])
      rescue Excon::Error::Forbidden => e
        puts "Error: Can't list members from team #{team.heroku['team']} with the given Heroku API Token. Please verify configuration"
        return
      rescue Excon::Error::NotFound => e
        puts "Error: Can't find team with name #{team.heroku['team']}. Please verify configuration"
        return
      end
      members.each do |member|
        puts "* #{member['email']}"
      end
      invites = @client.team_invitation.list(team.heroku['team'])
      if invites.any?
        puts "OK: #{team.heroku['team']} has the following pending invites in Heroku:"
        invites.each do |invite|
          puts "* #{invite['user']['email']}"
        end
      end
    end

    def create_heroku_team(project)
      if placeholder = @client.find_team_placeholder
        if @client.create_team_in_placeholder(project.heroku['team'], placeholder)
          puts "OK: The team #{project.heroku['team']} was created on Heroku"
          setup_pipeline(project)
        else
          puts "Warning: The team #{project.heroku['team']} is not available on Heroku. Please choose a different Heroku Team name."
        end
      else
        puts 'Warning: There are no placeholders accounts available on Heroku. ' \
              'Please contact DevOps team in order to solve this issue.'
      end
    end

    def setup_pipeline(project)
      if team = @client.find_team_by_name(project.heroku['team'])
        create_staging_app(team['name'], team)
        create_pipeline(team['name'], team)
        couple_pipeline_and_app
      else
        puts "Warning: The team #{project.heroku['team']} is not available on Heroku. Please contact DevOps team in order to solve this issue."
      end
    end

    private

    def create_staging_app(app_name, team)
      if @app = @client.create_staging_app_on_team(app_name, team)
        puts "OK: The app #{@app['name']} was created on Heroku"
      else
        puts "Warning: The name #{app_name} is not available on Heroku. Please contact DevOps team in order to solve this issue."
      end
    end

    def create_pipeline(pipeline_name, team)
      if @pipeline = @client.create_pipeline_on_team(pipeline_name, team)
        puts "OK: The pipeline #{@pipeline['name']} was created on Heroku"
      else
        puts "Warning: The pipeline #{pipeline_name} is not available on Heroku. Please contact DevOps team in order to solve this issue."
      end
    end

    def couple_pipeline_and_app
      if @client.create_pipeline_coupling(@app, @pipeline)
        puts 'OK: The pipeline and app were successfully coupled on Heroku'
      else
        puts 'Warning: An error occured while creating app or pipeline on Heroku.' \
              'Please contact DevOps team in order to solve this issue.'
      end
    end
  end
end
