module NullService
  # This class handle the behavior when a service handler in the application or when there is not
  # a configuration registered for a specific service in config/services.yml file
  class NullService
    def initialize(service)
      @service = service
    end

    def onboard(member:, configuration:) = result

    def offboard(member:, configuration:) = result

    def result = Result.new(:warning, "There is not handler for #{@service} in Able Gate")
  end
end
