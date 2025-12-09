# frozen_string_literal: true

require "pathname"

module CodeScanning
  class Rule
    def initialize(cop_name, severity = nil)
      @cop_name = cop_name
      @severity = severity.to_s
      @cop = RuboCop::Cop::Cop.registry.find_by_cop_name(cop_name)
    end

    def id
      @cop_name
    end

    def help(format)
      case format
      when :text
        "More info: #{help_uri}"
      when :markdown
        "[More info](#{help_uri})"
      end
    end

    def ==(other)
      badge.match?(other.badge)
    end
    alias eql? ==

    def badge
      @cop.badge
    end

    def sarif_severity
      cop_severity = @cop.new.send(:find_severity, nil, @severity)
      return cop_severity if %w[warning error].include?(cop_severity)
      return "note" if %w[refactor convention].include?(cop_severity)
      return "error" if cop_severity == "fatal"

      "none"
    end

    def help_uri
      return @cop.documentation_url if @cop.documentation_url
      return nil unless department_uri

      anchor = "#{badge.department}#{badge.cop_name}".downcase.tr("/", "")
      "#{department_uri}##{anchor}"
    end

    def department_uri
      case badge.department
      when :Performance
        "https://docs.rubocop.org/rubocop-performance/index.html"
      when :Packaging
        "https://docs.rubocop.org/rubocop-packaging/cops_packaging.html"
      when :Rails
        "https://docs.rubocop.org/rubocop-rails/cops_rails.html"
      when :Minitest
        "https://docs.rubocop.org/rubocop-minitest/cops_minitest.html"
      when :RSpec
        "https://docs.rubocop.org/rubocop-rspec/cops_rspec.html"
      when :"RSpec/Rails"
        "https://docs.rubocop.org/rubocop-rspec/cops_rspec_rails.html"
      when :"RSpec/Capybara"
        "https://docs.rubocop.org/rubocop-rspec/cops_rspec_capybara.html"
      when :"RSpec/FactoryBot"
        "https://docs.rubocop.org/rubocop-rspec/cops_rspec_factorybot.html"
      else
        STDERR.puts "WARNING: Unknown docs URI for department #{badge.department}"
        nil
      end
    end

    def to_json(opts = {})
      to_h.to_json(opts)
    end

    def cop_config
      @config ||= RuboCop::ConfigStore.new.for(Pathname.new(Dir.pwd))
      @cop_config ||= @config.for_cop(@cop.department.to_s)
                             .merge(@config.for_cop(@cop))
    end

    def to_h
      properties = {
        "precision" => "very-high"
      }

      h = {
        "id" => @cop_name,
        "name" => @cop_name.tr("/", "").gsub("RSpec", "Rspec"),
        "defaultConfiguration" => {
          "level" => sarif_severity
        },
        "properties" => properties
      }

      desc = cop_config["Description"]
      unless desc.nil?
        h["shortDescription"] = { "text" => desc }
        h["fullDescription"] = { "text" => desc }
        properties["description"] = desc
      end

      if badge.qualified?
        kind = badge.department.to_s
        properties["tags"] = [kind.downcase]
      end

      if help_uri
        properties["queryURI"] = help_uri

        h.merge!(
          "helpUri" => help_uri,
          "help" => {
            "text" => help(:text),
            "markdown" => help(:markdown)
          }
        )
      end

      h
    end
  end
end
