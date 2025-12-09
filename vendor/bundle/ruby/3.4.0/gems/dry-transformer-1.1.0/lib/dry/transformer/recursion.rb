# frozen_string_literal: true

module Dry
  module Transformer
    # Recursive transformation functions
    #
    # @example
    #   require 'dry/transformer/recursion'
    #
    #   include Dry::Transformer::Helper
    #
    #   fn = t(:hash_recursion, t(:symbolize_keys))
    #
    #   fn["name" => "Jane", "address" => { "street" => "Street 1" }]
    #   # => {:name=>"Jane", :address=>{:street=>"Street 1"}}
    #
    # @api public
    module Recursion
      extend Registry

      IF_ENUMERABLE = -> fn { Conditional[:is, Enumerable, fn] }

      IF_ARRAY = -> fn { Conditional[:is, Array, fn] }

      IF_HASH = -> fn { Conditional[:is, Hash, fn] }

      # Recursively apply the provided transformation function to an enumerable
      #
      # @example
      #   Dry::Transformer(
      #     :recursion, Dry::Transformer(:is, ::Hash, Dry::Transformer(:symbolize_keys))
      #   )[
      #     {
      #       'id' => 1,
      #       'name' => 'Jane',
      #       'tasks' => [
      #         { 'id' => 1, 'description' => 'Write some code' },
      #         { 'id' => 2, 'description' => 'Write some more code' }
      #       ]
      #     }
      #   ]
      #   => {
      #        :id=>1,
      #        :name=>"Jane",
      #        :tasks=>[
      #          {:id=>1, :description=>"Write some code"},
      #          {:id=>2, :description=>"Write some more code"}
      #        ]
      #      }
      #
      # @param [Enumerable]
      #
      # @return [Enumerable]
      #
      # @api public
      def self.recursion(value, fn)
        result = fn[value]
        guarded = IF_ENUMERABLE[-> v { recursion(v, fn) }]

        case result
        when ::Hash
          result.keys.each do |key|
            result[key] = guarded[result.delete(key)]
          end
        when ::Array
          result.map! do |item|
            guarded[item]
          end
        end

        result
      end

      # Recursively apply the provided transformation function to an array
      #
      # @example
      #   Dry::Transformer(:array_recursion, -> s { s.compact })[
      #     [['Joe', 'Jane', nil], ['Smith', 'Doe', nil]]
      #   ]
      #   # =>  [["Joe", "Jane"], ["Smith", "Doe"]]
      #
      # @param [Array]
      #
      # @return [Array]
      #
      # @api public
      def self.array_recursion(value, fn)
        result = fn[value]
        guarded = IF_ARRAY[-> v { array_recursion(v, fn) }]

        result.map! do |item|
          guarded[item]
        end
      end

      # Recursively apply the provided transformation function to a hash
      #
      # @example
      #   Dry::Transformer(:hash_recursion, Dry::Transformer(:symbolize_keys))[
      #     ["name" => "Jane", "address" => { "street" => "Street 1", "zipcode" => "123" }]
      #   ]
      #   # =>  {:name=>"Jane", :address=>{:street=>"Street 1", :zipcode=>"123"}}
      #
      # @param [Hash]
      #
      # @return [Hash]
      #
      # @api public
      def self.hash_recursion(value, fn)
        result = fn[value]
        guarded = IF_HASH[-> v { hash_recursion(v, fn) }]

        result.keys.each do |key|
          result[key] = guarded[result.delete(key)]
        end

        result
      end
    end
  end
end
