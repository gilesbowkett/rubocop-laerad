# frozen_string_literal: true

require "minitest/autorun"
require "rubocop"
require_relative "../lib/rubocop/laerad"

module CopTestHelper
  def fixture_path(name)
    File.expand_path("../../test/fixtures/#{name}", __dir__)
  end

  def analyze_fixture(name)
    path = fixture_path(name)
    source = File.read(path)
    analyze_source(source, path)
  end

  def analyze_source(source, path = "test.rb")
    processed_source = RuboCop::ProcessedSource.new(source, RUBY_VERSION.to_f, path)
    commissioner = RuboCop::Cop::Commissioner.new([cop], [], raise_error: true)
    result = commissioner.investigate(processed_source)
    @offenses = result.offenses
  end

  def cop
    @cop ||= RuboCop::Cop::Laerad::SingleUseVariable.new
  end

  def reset_cop
    @cop = nil
    @offenses = nil
  end

  def offenses
    @offenses || []
  end

  def offense_names
    offenses.map { |o| o.message.match(/`(\w+)`/)[1] }
  end
end
