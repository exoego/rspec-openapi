# frozen_string_literal: true

# Decides whether an RSpec run adds and updates without removing anything.
#
# A run narrowed to a subset is partial: spec files named on the command line,
# or an inclusion filter such as -e, --tag, a line number or a leftover `fit`.
# A directory counts as a full run, because `rspec spec/requests` is the usual
# way to regenerate the whole document. An exclusion filter like `--tag ~slow`
# does not narrow either, so a CI run that uses one still cleans up.
module RSpec::OpenAPI::PartialRun
  class << self
    def rspec?
      configured = RSpec::OpenAPI.partial_update
      return configured unless configured.nil?

      files_named? || RSpec.configuration.inclusion_filter.rules.any?
    end

    # Printed when the run decided on its own, since a partial run keeps what
    # a full run would remove.
    def notice
      return unless RSpec::OpenAPI.partial_update.nil? && RSpec::OpenAPI.path_records.any? && rspec?

      'rspec-openapi: the run was narrowed, so nothing was removed from the document. ' \
        'Run all specs to remove what no longer exists.'
    end

    private

    # `spec/a_spec.rb:12` names a file with a line filter.
    def files_named?
      ARGV.any? { |arg| File.file?(arg.sub(/(:\d+)+\z/, '')) }
    end
  end
end
