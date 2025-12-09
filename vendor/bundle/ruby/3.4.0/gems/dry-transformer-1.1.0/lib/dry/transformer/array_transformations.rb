# frozen_string_literal: true

module Dry
  module Transformer
    # Transformation functions for Array objects
    #
    # @example
    #   require 'dry/transformer/array'
    #
    #   include Dry::Transformer::Helper
    #
    #   fn = t(:map_array, t(:symbolize_keys)) >> t(:wrap, :address, [:city, :zipcode])
    #
    #   fn.call(
    #     [
    #       { 'city' => 'Boston', 'zipcode' => '123' },
    #       { 'city' => 'NYC', 'zipcode' => '312' }
    #     ]
    #   )
    #   # => [{:address=>{:city=>"Boston", :zipcode=>"123"}},
    #   #    {:address=>{:city=>"NYC", :zipcode=>"312"}}]
    #
    # @api public
    module ArrayTransformations
      extend Registry

      # Map array values using transformation function
      #
      # @example
      #
      #   fn = Dry::Transformer(:map_array, -> v { v.upcase })
      #
      #   fn.call ['foo', 'bar'] # => ["FOO", "BAR"]
      #
      # @param [Array] array The input array
      # @param [Proc] fn The transformation function
      #
      # @return [Array]
      #
      # @api public
      def self.map_array(array, fn)
        Array(array).map { |value| fn[value] }
      end

      # Wrap array values using HashTransformations.nest function
      #
      # @example
      #   fn = Dry::Transformer(:wrap, :address, [:city, :zipcode])
      #
      #   fn.call [{ city: 'NYC', zipcode: '123' }]
      #   # => [{ address: { city: 'NYC', zipcode: '123' } }]
      #
      # @param [Array] array The input array
      # @param [Object] key The nesting root key
      # @param [Object] keys The nesting value keys
      #
      # @return [Array]
      #
      # @api public
      def self.wrap(array, key, keys)
        nest = HashTransformations[:nest, key, keys]
        array.map { |element| nest.call(element) }
      end

      # Group array values using provided root key and value keys
      #
      # @example
      #   fn = Dry::Transformer(:group, :tags, [:tag])
      #
      #   fn.call [
      #     { task: 'Group it', tag: 'task' },
      #     { task: 'Group it', tag: 'important' }
      #   ]
      #   # => [{ task: 'Group it', tags: [{ tag: 'task' }, { tag: 'important' }]]
      #
      # @param [Array] array The input array
      # @param [Object] key The nesting root key
      # @param [Object] keys The nesting value keys
      #
      # @return [Array]
      #
      # @api public
      def self.group(array, key, keys)
        grouped = Hash.new { |h, k| h[k] = [] }
        array.each do |hash|
          hash = Hash[hash]

          old_group = Coercions.to_tuples(hash.delete(key))
          new_group = keys.inject({}) { |a, e| a.merge(e => hash.delete(e)) }

          grouped[hash] << old_group.map { |item| item.merge(new_group) }
        end
        grouped.map do |root, children|
          root.merge(key => children.flatten)
        end
      end

      # Ungroup array values using provided root key and value keys
      #
      # @example
      #   fn = Dry::Transformer(:ungroup, :tags, [:tag])
      #
      #   fn.call [
      #     { task: 'Group it', tags: [{ tag: 'task' }, { tag: 'important' }] }
      #   ]
      #   # => [
      #     { task: 'Group it', tag: 'task' },
      #     { task: 'Group it', tag: 'important' }
      #   ]
      #
      # @param [Array] array The input array
      # @param [Object] key The nesting root key
      # @param [Object] keys The nesting value keys
      #
      # @return [Array]
      #
      # @api public
      def self.ungroup(array, key, keys)
        array.flat_map { |item| HashTransformations.split(item, key, keys) }
      end

      def self.combine(array, mappings)
        Combine.combine(array, mappings)
      end

      # Converts the array of hashes to array of values, extracted by given key
      #
      # @example
      #   fn = t(:extract_key, :name)
      #   fn.call [
      #     { name: 'Alice', role: 'sender' },
      #     { name: 'Bob', role: 'receiver' },
      #     { role: 'listener' }
      #   ]
      #   # => ['Alice', 'Bob', nil]
      #
      # @param [Array<Hash>] array The input array of hashes
      # @param [Object] key The key to extract values by
      #
      # @return [Array]
      #
      # @api public
      def self.extract_key(array, key)
        map_array(array, ->(v) { v[key] })
      end

      # Wraps every value of the array to tuple with given key
      #
      # The transformation partially inverses the `extract_key`.
      #
      # @example
      #   fn = t(:insert_key, 'name')
      #   fn.call ['Alice', 'Bob', nil]
      #   # => [{ 'name' => 'Alice' }, { 'name' => 'Bob' }, { 'name' => nil }]
      #
      # @param [Array<Hash>] array The input array of hashes
      # @param [Object] key The key to extract values by
      #
      # @return [Array]
      #
      # @api public
      def self.insert_key(array, key)
        map_array(array, ->(v) { {key => v} })
      end

      # Adds missing keys with nil value to all tuples in array
      #
      # @param [Array] keys
      #
      # @return [Array]
      #
      # @api public
      #
      def self.add_keys(array, keys)
        base = keys.inject({}) { |a, e| a.merge(e => nil) }
        map_array(array, ->(v) { base.merge(v) })
      end
    end
  end
end
