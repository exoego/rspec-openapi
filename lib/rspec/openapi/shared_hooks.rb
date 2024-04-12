module SharedHooks
  def self.find_extractor
    if defined?(Rails) && Rails.respond_to?(:application) && Rails.application
      RSpec::OpenAPI::Extractors::Rails
    elsif defined?(Hanami) && Hanami.respond_to?(:app) && Hanami.app?
      RSpec::OpenAPI::Extractors::Hanami
      # elsif defined?(Roda)
      #   some Roda extractor
    else
      RSpec::OpenAPI::Extractors::Rack
    end
  end
end
