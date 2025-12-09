# frozen_string_literal: true

module Dry
  module Transformer
    module ArrayTransformations
      class Combine
        EMPTY_ARRAY = [].freeze

        class << self
          def combine(array, mappings)
            root, nodes = array
            return EMPTY_ARRAY if root.nil?
            return root if nodes.nil?

            groups = group_nodes(nodes, mappings)

            root.map do |element|
              element.dup.tap { |copy| add_groups_to_element(copy, groups, mappings) }
            end
          end

          private

          def add_groups_to_element(element, groups, mappings)
            groups.each_with_index do |candidates, index|
              mapping = mappings[index]
              resource_key = mapping[0]
              element[resource_key] = element_candidates(element, candidates, mapping[1].keys)
            end
          end

          def element_candidates(element, candidates, keys)
            candidates[element_candidates_key(element, keys)] || EMPTY_ARRAY
          end

          def group_nodes(nodes, mappings)
            nodes.each_with_index.map do |candidates, index|
              mapping = mappings[index]
              group_candidates(candidates, mapping)
            end
          end

          def group_candidates(candidates, mapping)
            nested_mapping = mapping[2]
            candidates = combine(candidates, nested_mapping) unless nested_mapping.nil?
            group_candidates_by_keys(candidates, mapping[1].values)
          end

          def group_candidates_by_keys(candidates, keys)
            return candidates.group_by { |a| a.values_at(*keys) } if keys.size > 1

            key = keys.first
            candidates.group_by { |a| a[key] }
          end

          def element_candidates_key(element, keys)
            return element.values_at(*keys) if keys.size > 1

            element[keys.first]
          end
        end
      end
    end
  end
end
