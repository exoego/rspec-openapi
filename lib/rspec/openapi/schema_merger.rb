class << RSpec::OpenAPI::SchemaMerger = Object.new
  # @param [Hash] base
  # @param [Hash] spec
  def merge!(base, spec)
    # TODO: implement deep merge, and then more intelligent merges
    base.merge!(spec)
  end
end
