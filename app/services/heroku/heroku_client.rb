require 'platform-api'

module Heroku
  class HerokuClient < SimpleDelegator
    def initialize(access_token)
      super(PlatformAPI.connect_oauth(access_token))
    end

    def find_team_by_name(team_name)
      team.list.find do |team|
        team['name'] == (team_name)
      end
    end

    def find_team_placeholder
      team.list.find do |team|
        team['name'].include?('placeholder-team')
      end
    end

    def find_teams_by_member(email)
      team.list.select do |team|
        team if team_member.list(team['id']).find { |member| member['email'] == email }
      end
    end

    def find_membership(team, email)
      find_teams_by_member(email).find do |membership|
        membership['id'] == team['id']
      end
    end

    def create_team_in_placeholder(team_name, placeholder)
      team.update(placeholder['id'], default: true, name: team_name)
    rescue StandardError
      false
    end

    def create_pipeline_on_team(pipeline_name, team)
      pipeline.create(name: pipeline_name, owner: { id: team['id'], type: 'team' })
    end

    def create_staging_app_on_team(app_name, team)
      team_app.create(name: "#{app_name}-staging", team: team['name'])
    end

    def create_pipeline_coupling(app, pipeline)
      pipeline_coupling.create(app: app['id'], pipeline: pipeline['id'], stage: 'staging')
    end
  end
end
