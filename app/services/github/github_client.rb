require 'octokit'

module Github
  class GithubClient < SimpleDelegator
    attr_reader :organization

    def initialize(access_token, organization)
      Octokit.configure do |c|
        c.auto_paginate = true
      end
      super(Octokit::Client.new(access_token: access_token))
      @organization = organization
    end

    def find_team_by_name(team_name)
      organization_teams(@organization).find do |team|
        team['slug'] == team_name
      end
    end

    def member_belongs_to_org?(member)
      query = <<~GRAPHQL
        query {
          user(login: "#{member}"){
            organizations(first: 100) {
              nodes {
                name
              }
            }
          }
        }
      GRAPHQL

      member_organizations = post('/graphql', { query: query }.to_json)
                             .to_hash.dig(:data, :user, :organizations, :nodes) || []
      member_organizations.any? { |org| org[:name] == @organization }
    end

    def find_teams_by_member(member)
      query = <<~GRAPHQL
        query {
          organization(login: "#{@organization}") {
            teams(first: 100, userLogins: ["#{member}"]) {
              nodes{
                slug
              }
            }
          }
        }
      GRAPHQL

      post('/graphql', { query: query }.to_json)
        .to_hash.dig(:data, :organization, :teams, :nodes) || []
    end

    def team_belongs_to_org?(team)
      query = <<~GRAPHQL
        query {
          organization(login: "#{@organization}") {
            teams(first: 10, query: "#{team}") {
              nodes {
                slug
              }
            }
          }
        }
      GRAPHQL

      teams = post('/graphql', { query: query }.to_json)
              .to_hash.dig(:data, :organization, :teams, :nodes) || []

      !teams.empty?
    end

    def find_members_by_team(team)
      query = <<~GRAPHQL
        query {
          organization(login: "#{@organization}") {
            team(slug: "#{team}") {
              members {
                nodes {
                  login
                }
              }
            }
          }
        }
      GRAPHQL

      post('/graphql', { query: query }.to_json)
        .to_hash.dig(:data, :organization, :team, :members, :nodes) || []
    end

    def has_team_membership(team_id, github_handle)
      team_membership(team_id, github_handle)
      true
    rescue Octokit::NotFound
      false
    end

    def create_team_in_organization(team_name)
      team = create_team(@organization, name: team_name, privacy: 'closed')
    end

    def create_repository(repository_name)
      create_repo(
        repository_name,
        organization: @organization,
        private: 'true'
      )
    end

    def find_repository(repository_name)
      repository?(name: repository_name, owner: @organization)
    end
  end
end
