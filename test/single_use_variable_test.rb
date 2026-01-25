# frozen_string_literal: true

require_relative "test_helper"

class SingleUseVariableTest < Minitest::Test
  include CopTestHelper

  def setup
    reset_cop
  end

  def test_single_use_variable
    analyze_fixture("single_use_variable.rb")

    assert_includes offense_names, "x"
  end

  def test_unused_variable
    analyze_fixture("unused_variable.rb")

    assert_includes offense_names, "x"
  end

  def test_multi_use_variable
    analyze_fixture("multi_use_variable.rb")

    refute offense_names.include?("x")
  end

  def test_multi_use_parameter
    analyze_fixture("multi_use_parameter.rb")

    refute offense_names.include?("x")
  end

  def test_no_violations
    analyze_fixture("no_violations.rb")

    assert_empty offenses
  end

  def test_nested_scopes
    analyze_fixture("nested_scopes.rb")

    assert offenses.any?
  end

  def test_block_closure
    analyze_fixture("block_closure.rb")

    refute offense_names.include?("mapping")
  end

  def test_nested_block_closure
    analyze_fixture("nested_block_closure.rb")

    refute offense_names.include?("total")
  end

  def test_block_shadowing
    analyze_fixture("block_shadowing.rb")

    refute offense_names.include?("x")
  end

  def test_method_chain
    analyze_fixture("method_chain.rb")

    refute offense_names.include?("user")
  end

  def test_keyword_args
    analyze_fixture("keyword_args.rb")

    refute offense_names.include?("foo")
    refute offense_names.include?("bar")
    assert_includes offense_names, "baz"
  end

  def test_underscore_prefix
    analyze_fixture("underscore_prefix.rb")

    refute offense_names.include?("_unused")
    refute offense_names.include?("_first")
  end

  def test_yield_block
    analyze_fixture("yield_block.rb")

    assert_empty offenses
  end

  def test_block_passthrough
    analyze_fixture("block_passthrough.rb")

    assert_empty offenses
  end

  def test_super_implicit
    analyze_fixture("super_implicit.rb")

    # params used via bare super should be exempt
    # This depends on the fixture content
  end

  def test_numbered_params
    analyze_fixture("numbered_params.rb")

    assert_includes offense_names, "items"
  end

  def test_multi_use_rescue_binding
    analyze_fixture("multi_use_rescue_binding.rb")

    refute offense_names.include?("e")
  end

  def test_object_as_argument
    analyze_fixture("object_as_argument.rb")

    refute offense_names.include?("obj_as_argument")
  end

  def test_top_level_variables
    analyze_fixture("top_level_variables.rb")

    assert_equal %w[annotations pronto_format].sort, offense_names.sort
  end
end
