require 'bamboozled'

module BambooHr
  class BambooHr
    def onboard(member:, configuration:)
      @client = Bamboozled.client(
        subdomain: ENV.fetch('BAMBOOHR_SUBDOMAIN'),
        api_key: ENV.fetch('BAMBOOHR_API_KEY')
      )

      employee = @client.employee.add(
        firstName: member.first_name,
        lastName: member.last_name,
        workEmail: member.email
      )
      employee_url = employee['headers']['location']
      bamboohr_id = employee_url.match /(\d+)$/
      Result.new(:success, "OK: #{member.email} was added to BambooHR with bamboohr_id #{bamboohr_id}")
    end

    def offboard(member:, configuration:)
      employees = @client.employee.all(%w[workEmail status])
      employee = employees.find { |employee| employee['workEmail'] == member.email }

      if employee.nil?
        return Result.new(:warning,
                          "WARNING: #{member.email} either it's not registered yet, hasn't employment status, or is already marked as inactive in BambooHR")
      end

      if employee['status'] != 'Inactive'
        @client.employee.update employee['id'], status: 'inactive'
        Result.new(:success, "OK: #{member.email} was set as inactive in BambooHR")
      else
        Result.new(:warning, "#{member.email} is already inactive")
      end
    end
  end
end
