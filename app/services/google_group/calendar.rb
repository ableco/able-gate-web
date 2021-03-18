module GoogleGroup
  class Calendar
    ROLE_OWNER = 'OWNER'
    ROLE_MEMBER = 'MEMBER'

    def onboard(member:, configuration:)
      @configuration = configuration

      @client = GoogleClient.new(
        ENV['GOOGLE_CLIENT_ID'],
        ENV['GOOGLE_CLIENT_SECRET'],
        ENV['GOOGLE_REFRESH_TOKEN'],
        @configuration['google_domain']
      )

      if department_calendars = onboarding_calendars
        department_calendars.each do |department_calendar|
          if calendar = @client.find_calendar_by_name(department_calendar)
            @client.next_events(calendar.id).each do |event|
              next unless event.summary.start_with?(*calendar_prefixes(member.department_key))

              @client.invite_to_event(calendar.id, event, member.email)
              return Result.new(:success,
                                "OK: #{member.email} was succesfully invited to the event '#{event.summary}' in Google Calendar")
            end
          else
            return Result.new(:error,
                              "Error: Can't find calendar: #{department_calendar}. Please verify your configuration")
          end
        end
      else
        Result.new(:error,
                   "Error: Can't find #{member.department} department in the config file. Please verify your configuration")
      end
    end

    def offboard(member:, configuration:); end

    def onboarding_calendars
      [@configuration['onboarding_calendar']]
    end

    def calendar_prefixes(department)
      calendar_prefixes = [@configuration['calendar_prefix']]
      if department_prefix = @configuration['departments'][department]['calendar_prefix']
        calendar_prefixes << department_prefix
      end
    end
  end
end
