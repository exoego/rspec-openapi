# frozen_string_literal: true

require_relative "../code_scanning"

class QHelpGenerator
  def initialize
    @formatter = CodeScanning::SarifFormatter.new(nil)
  end

  def parse_file(path_to_file)
    file = File.open(path_to_file)
    current_rule = nil
    file.each_with_index do |line, index|
      # title: skip
      next if index.zero?

      if line[0..2] == "## "
        current_cop = line[3..-2]
        current_rule, _index = @formatter.get_rule(current_cop, nil)
        next
      end

      next if current_rule.nil?
      if line == "\n" && current_rule.help_empty?
        # Don't start the help text with new lines
        next
      end

      current_rule.append_help(line)
    end
  end

  def sarif_json
    @formatter.sarif_json
  end
end
