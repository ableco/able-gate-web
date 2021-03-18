require 'googleauth'
require 'google/apis/admin_directory_v1'
require 'google/apis/cloudresourcemanager_v1'
require 'google/apis/calendar_v3'

module GoogleGroup
  MAX_RESULTS = 500
  MONTHS_RANGE = 6

  class GoogleClient < SimpleDelegator
    attr_reader :domain

    SCOPES = [
      'https://www.googleapis.com/auth/admin.directory.user',
      'https://www.googleapis.com/auth/admin.directory.group',
      'https://www.googleapis.com/auth/cloud-platform',
      'https://www.googleapis.com/auth/calendar'
    ]

    def initialize(client_id, client_secret, refresh_token, domain)
      credentials = ::Google::Auth::UserRefreshCredentials.new(
        client_id: client_id,
        client_secret: client_secret,
        scope: SCOPES,
        additional_parameters: { access_type: :offline }
      )

      credentials.refresh_token = refresh_token
      credentials.fetch_access_token!

      @client = ::Google::Apis::AdminDirectoryV1::DirectoryService.new
      @calendar = ::Google::Apis::CalendarV3::CalendarService.new
      @cloud_resource = ::Google::Apis::CloudresourcemanagerV1::CloudResourceManagerService.new

      @client.authorization = credentials
      @calendar.authorization = credentials
      @cloud_resource.authorization = credentials

      super(@client)
      @domain = domain
    end

    def groups
      list_groups(domain: @domain, max_results: MAX_RESULTS).groups
    end

    def find_group_by_name(group_name)
      groups.find do |group|
        group.email == group_name
      end
    end

    def has_group_membership(group_id, email)
      members = list_members(group_id, max_results: MAX_RESULTS)

      return false if members.members.nil?

      members.members.any? do |member|
        member.email == email
      end
    end

    def add_group_membership(group_id, email, role)
      new_member = ::Google::Apis::AdminDirectoryV1::Member.new(email: email, role: role)
      insert_member(group_id, new_member)
    end

    def remove_group_membership(group_id, email)
      delete_member(group_id, email) == ''
    rescue StandardError
      false
    end

    def create_calendar(project_name)
      new_calendar = ::Google::Apis::CalendarV3::CalendarListEntry.new(summary: project_name)
      @calendar.insert_calendar(new_calendar)
    end

    def calendars
      @calendar.list_calendar_lists(max_results: MAX_RESULTS).items
    end

    def events(calendar_id, start_date = DateTime.now)
      @calendar.list_events(
        calendar_id,
        max_results: MAX_RESULTS,
        single_events: true,
        order_by: 'startTime',
        time_min: start_date.rfc3339,
        time_max: start_date.next_month(MONTHS_RANGE).rfc3339
      ).items
    end

    def next_events(calendar_id)
      next_events = []
      summaries = []
      events(calendar_id).each do |event|
        unless summaries.include? event.summary
          next_events << event
          summaries << event.summary
        end
      end
      next_events
    end

    def invite_to_event(calendar_id, event, email)
      event.attendees ||= []
      event.attendees << { email: email }
      @calendar.update_event(calendar_id, event.id, event)
    end

    def find_calendar_by_name(name)
      calendars.find do |calendar|
        calendar.summary == name
      end
    end

    def create_group(email)
      new_group = ::Google::Apis::AdminDirectoryV1::Group.new(email: email)
      insert_group(new_group)
    end

    def create_project(project_name)
      new_project = ::Google::Apis::CloudresourcemanagerV1::Project.new(
        name: project_name,
        project_id: "#{project_name}-#{Time.now.to_i}"
      )
      @cloud_resource.create_project(new_project)
    end

    def add_project_membership(project_id, email)
      new_policy = policy(project_id)
      editors = project_editors(project_id)
      new_policy.bindings.push(
        ::Google::Apis::CloudresourcemanagerV1::Binding.new(
          members: ["user:#{email}"],
          role: 'roles/editor'
        )
      )

      new_policy_request = ::Google::Apis::CloudresourcemanagerV1::SetIamPolicyRequest.new(
        policy: new_policy,
        update_mask: 'bindings'
      )

      @cloud_resource.set_project_iam_policy(project_id, new_policy_request)
    end

    def find_editor_in_project(project_id, email)
      editors = project_editors(project_id)
      editors && editors.members.include?("user:#{email}")
    end

    def policy(project_id)
      @cloud_resource.get_project_iam_policy(project_id)
    end

    def project_editors(project_id)
      editors = policy(project_id).bindings.find do |binding|
        binding.role == 'roles/editor'
      end
    end

    def find_project_by_name(project_name)
      projects = @cloud_resource.list_projects(
        page_size: MAX_RESULTS,
        filter: "name:#{project_name}"
      ).projects ||= []

      projects.find do |project|
        project.lifecycle_state != 'DELETE_REQUESTED'
      end
    end
  end
end
