# Load data from config/services.yml
class Services
  class << self
    CONFIG = Rails.application.config_for(:services)
    INSTANCES_CACHE = {}

    def [](identifier)
      return INSTANCES_CACHE[identifier] if INSTANCES_CACHE.key?(identifier)

      service_config_key = CONFIG[identifier]

      return INSTANCES_CACHE[identifier] = NullService::NullService.new(identifier) unless service_config_key

      INSTANCES_CACHE[identifier] =
        Object.const_defined?(service_config_key) ? Object.const_get(service_config_key).new : NullService::NullService.new(identifier)
    end
  end
end
