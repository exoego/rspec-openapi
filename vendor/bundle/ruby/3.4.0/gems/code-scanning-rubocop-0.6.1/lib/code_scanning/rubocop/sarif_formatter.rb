# frozen_string_literal: true

require "json"
require_relative "rule"

module CodeScanning
  class SarifFormatter < RuboCop::Formatter::BaseFormatter
    def initialize(output, options = {})
      super
      @sarif = {
        "$schema" => "https://raw.githubusercontent.com/oasis-tcs/sarif-spec/master/Schemata/sarif-schema-2.1.0.json",
        "version" => "2.1.0"
      }
      @rules_map = {}
      @rules = []
      @results = []
      @sarif["runs"] = [
        {
          "tool" => {
            "driver" => {
              "name" => "RuboCop",
              "version" => RuboCop::Version.version,
              "informationUri" => "https://rubocop.org",
              "rules" => @rules
            }
          },
          "results" => @results
        }
      ]
    end

    def get_rule(cop_name, severity)
      r = @rules_map[cop_name]
      if r.nil?
        rule = Rule.new(cop_name, severity&.name)
        r = @rules_map[cop_name] = [rule, @rules.size]
        @rules << rule
      end

      r
    end

    def file_finished(file, offenses)
      relative_path = RuboCop::PathUtil.relative_path(file)

      offenses.each do |o|
        rule, rule_index = get_rule(o.cop_name, o.severity)
        @results << {
          "ruleId" => rule.id,
          "ruleIndex" => rule_index,
          "message" => {
            "text" => o.message
          },
          "locations" => [
            {
              "physicalLocation" => {
                "artifactLocation" => {
                  "uri" => relative_path,
                  "uriBaseId" => "%SRCROOT%",
                },
                "region" => {
                  "startLine" => o.line,
                  "startColumn" => o.real_column,
                  "endColumn" => o.last_column.zero? ? o.real_column : o.last_column
                }
              }
            }
          ]
        }
      end
    end

    def finished(_inspected_files)
      output.print(sarif_json)
    end

    def sarif_json
      JSON.pretty_generate(@sarif)
    end
  end
end
