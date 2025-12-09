require 'patience_diff/html/escaping'

module PatienceDiff
  module Html
    class HeaderHelper
      include Escaping
      attr_accessor :left_header, :right_header, :header_id
      
      def initialize(left_header, right_header, header_id)
        @left_header = left_header
        @right_header = right_header
        @header_id = header_id
      end
    end
  end
end
