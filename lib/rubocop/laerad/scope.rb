# frozen_string_literal: true

module RuboCop
  module Laerad
    class Scope
      attr_reader :variables, :variable_def_locations, :exempt_variables, :param_names

      def initialize
        @variables = Hash.new(0)
        @variable_def_locations = Hash.new { |h, k| h[k] = [] }
        @exempt_variables = Set.new
        @param_names = Set.new
      end

      def register_variable_def(name, location)
        @variables[name] += 1
        @variable_def_locations[name] << location
      end

      def register_variable_ref(name)
        @variables[name] += 1
      end

      def single_use_variables
        @variables.select { |_, count| count <= 2 }.keys
      end

      def variable_definition_location(name)
        @variable_def_locations[name].first
      end

      def variable_count(name)
        @variables[name]
      end

      def variable_defined?(name)
        @variable_def_locations.key?(name)
      end
    end
  end
end
