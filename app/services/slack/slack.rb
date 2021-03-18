require 'slack-ruby-client'

module Slack
  class Slack
    attr_reader :organization

    def onboard(member:, configuration:)
      @client = ::Slack::Web::Client.new(token: ENV.fetch('SLACK_API_TOKEN'))
      @client_legacy = ::Slack::Web::Client.new(token: ENV.fetch('SLACK_API_LEGACY_TOKEN'))
      @channels = configuration['channels']
      @channel_suffixes = ['', '-announcements', '-product', '-development', '-notifications']

      invite_user_to_workpace(member.email, @channels)
    end

    def offboard(member:, configuration:)
      @client = ::Slack::Web::Client.new(token: ENV.fetch('SLACK_API_TOKEN'))
      @client_legacy = ::Slack::Web::Client.new(token: ENV.fetch('SLACK_API_LEGACY_TOKEN'))

      user_id = @client.users_lookupByEmail(email: member.email)['user']['id']
      @client_legacy.users_admin_setInactive user: user_id
      Result.new(:success, "OK: #{member.email} was desactivated from Slack")
    end

    def start(project:)
      channel_list = @channel_suffixes.map { |channel_sufix| "#{project.name}#{channel_sufix}" }

      channel_list.each do |channel|
        if !channel_was_created(channel)
          @client.channels_create(name: channel)
          puts "OK: The following channel was created in Slack: #{channel}"
        else
          puts "Warning: The following channel already existed in Slack: #{channel}"
        end
      end
    end

    def send_notification(channel:, message: 'Default notification')
      if channel
        begin
          response = @client.chat_postMessage(
            channel: channel,
            text: message
            # as_user: true
          )
          handle_response("A notification was sent to #{channel}")
        rescue Exception => e
          handle_error("Can't send a notification: #{e}")
        end
      else
        error_response = "Can't send a notification. " \
          "Please verify the notifications_channel in the team's configuration"

        handle_error(error_response)
      end
    end

    private

    def channel_was_created(name)
      channels.find { |c| c.name == name }
    end

    def channels
      @client.channels_list.channels
    end

    def invite_user_to_workpace(email, channels)
      channels_ids = channel_ids_by channel_names: channels
      ids = channels_ids.join(',')
      @client_legacy.users_admin_invite email: email, channels: ids
      Result.new(:success, "OK: #{email} invited to join to Slack and channels #{channels}")
    end

    def channel_ids_by(channel_names:)
      info = @client.conversations_list(
        types: 'private_channel, public_channel',
        exclude_archived: true
      )
      channels_hash = Hash[info.channels.collect { |channel| [channel.name, channel.id] }]
      channels_ids = []
      channel_names.each { |name| channels_ids.push channels_hash.fetch name }
      channels_ids
    end
  end
end
