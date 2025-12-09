require 'pathname'
require 'patience_diff/differ'
require 'patience_diff/formatter'
require 'patience_diff/formatting_context'
require 'patience_diff/sequence_matcher'
require 'patience_diff/usage_error'
PatienceDiff.autoload(:Html, 'patience_diff/html/formatter')

module PatienceDiff
  VERSION = "1.2.0"
  TEMPLATE_PATH = Pathname(File.join(File.dirname(__FILE__),'..','templates')).realpath
end
