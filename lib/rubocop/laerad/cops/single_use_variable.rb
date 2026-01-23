# frozen_string_literal: true

module RuboCop
  module Cop
    module Laerad
      class SingleUseVariable < Base
        MSG = "Single-use variable `%<name>s` detected."

        def on_new_investigation
          @scope_stack = [RuboCop::Laerad::Scope.new]
          @method_nodes = []
          @in_compound_asgn = false
        end

        def on_investigation_end
          return if @scope_stack.empty?
          check_scope(@scope_stack.first)
        end

        # Scope-introducing nodes - push on entry

        def on_def(node)
          push_scope
          register_params(node.arguments)
          @method_nodes.push(node)
        end

        def on_defs(node)
          push_scope
          register_params(node.arguments)
          @method_nodes.push(node)
        end

        def on_block(node)
          push_scope
          register_block_params(node)
        end

        def on_numblock(node)
          push_scope
        end

        # Scope-introducing nodes - pop on exit

        def after_def(node)
          check_yield_exemption(node)
          check_zsuper_exemption(node)
          pop_scope_and_check
          @method_nodes.pop
        end

        def after_defs(node)
          check_yield_exemption(node)
          check_zsuper_exemption(node)
          pop_scope_and_check
          @method_nodes.pop
        end

        def after_block(_node)
          pop_scope_and_check
        end

        def after_numblock(_node)
          pop_scope_and_check
        end

        # Variable tracking

        def on_lvasgn(node)
          # Skip if this lvasgn is part of a compound assignment (handled by on_op_asgn etc.)
          return if @in_compound_asgn

          name = node.children.first.to_s
          location = node.loc.name || node.loc.expression

          # If variable exists in outer scope, this is a reassignment (reference), not a new def
          if (defining_scope = find_defining_scope(name))
            defining_scope.register_variable_ref(name)
          else
            current_scope.register_variable_def(name, location)
          end
        end

        def on_lvar(node)
          name = node.children.first.to_s
          scope = find_defining_scope(name) || current_scope
          scope.register_variable_ref(name)
        end

        # Compound assignment (x += 1) - the read is implicit in the operation
        def on_op_asgn(node)
          @in_compound_asgn = true
          target = node.children.first
          return unless target.lvasgn_type?

          name = target.children.first.to_s
          location = target.loc.name || target.loc.expression
          if (defining_scope = find_defining_scope(name))
            defining_scope.register_variable_ref(name)
          else
            # New variable - register def
            current_scope.register_variable_def(name, location)
          end
        end

        def after_op_asgn(_node)
          @in_compound_asgn = false
        end

        # x ||= 1
        def on_or_asgn(node)
          @in_compound_asgn = true
          handle_compound_asgn(node)
        end

        def after_or_asgn(_node)
          @in_compound_asgn = false
        end

        # x &&= 1
        def on_and_asgn(node)
          @in_compound_asgn = true
          handle_compound_asgn(node)
        end

        def after_and_asgn(_node)
          @in_compound_asgn = false
        end

        # Method calls - receivers are handled by on_lvar when RuboCop walks children
        # No special handling needed here

        private

        def current_scope
          @scope_stack.last
        end

        def push_scope
          @scope_stack.push(RuboCop::Laerad::Scope.new)
        end

        def pop_scope_and_check
          scope = @scope_stack.pop
          check_scope(scope)
        end

        def check_scope(scope)
          scope.single_use_variables.each do |name|
            next if name.start_with?("_")
            next if scope.exempt_variables.include?(name)
            next if scope.block_param_names.include?(name)

            location = scope.variable_definition_location(name)
            next unless location

            add_offense(location, message: format(MSG, name: name))
          end
        end

        def find_defining_scope(name)
          @scope_stack.reverse.find { |s| s.variable_defined?(name) }
        end

        def handle_compound_asgn(node)
          target = node.children.first
          return unless target.lvasgn_type?

          name = target.children.first.to_s
          location = target.loc.name || target.loc.expression
          if (defining_scope = find_defining_scope(name))
            defining_scope.register_variable_ref(name)
          else
            current_scope.register_variable_def(name, location)
          end
        end

        def register_params(args_node)
          return unless args_node

          args_node.children.each do |arg|
            register_single_param(arg)
          end
        end

        def register_block_params(block_node)
          return unless block_node.arguments

          block_node.arguments.children.each do |arg|
            register_single_param(arg)
            name = arg.children.first&.to_s
            current_scope.block_param_names.add(name) if name
          end
        end

        def register_single_param(arg)
          return unless arg

          name = case arg.type
                 when :arg, :optarg, :restarg, :kwarg, :kwoptarg, :kwrestarg, :blockarg
                   arg.children.first&.to_s
                 when :shadowarg
                   arg.children.first&.to_s
                 end

          if name
            location = arg.loc.name || arg.loc.expression
            current_scope.register_variable_def(name, location)
            current_scope.param_names.add(name)
          end
        end

        def check_yield_exemption(node)
          if contains_yield?(node)
            block_param = find_block_param(node.arguments)
            current_scope.exempt_variables.add(block_param) if block_param
          end
        end

        def check_zsuper_exemption(node)
          if contains_zsuper?(node)
            current_scope.param_names.each do |name|
              current_scope.exempt_variables.add(name)
            end
          end
        end

        def find_block_param(args_node)
          return unless args_node

          args_node.children.each do |arg|
            return arg.children.first&.to_s if arg.type == :blockarg
          end
          nil
        end

        def contains_yield?(node)
          return false unless node

          node.each_descendant(:yield).any?
        end

        def contains_zsuper?(node)
          return false unless node

          node.each_descendant(:zsuper).any?
        end
      end
    end
  end
end
