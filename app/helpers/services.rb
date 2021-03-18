# Load data from config/services.yml
class Services
  class << self
    CONFIG = Rails.application.config_for(:services)

    def [](identifier)
      Object.const_get(CONFIG[identifier])
    end
  end
end
