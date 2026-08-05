# frozen_string_literal: true

# Deliberately broken. A per-directory config file is loaded next to the
# document it configures, and a mistake in one must not take the whole suite
# down with it: rspec-openapi warns and carries on writing the document.
# spec/requests/rails_broken_config_spec.rb covers that.
raise 'boom from a per-directory config file'
