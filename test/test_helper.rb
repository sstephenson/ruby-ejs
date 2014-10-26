require "minitest/autorun"
require 'minitest/reporters'
require "ejs"

FUNCTION_PATTERN = /\A\s*function\s*\(.*?\)\s*\{(.*?)\}\Z/m

BRACE_SYNTAX = {
  :evaluation_pattern    => /\{\{([\s\S]+?)\}\}/,
  :interpolation_pattern => /\{\{=([\s\S]+?)\}\}/,
  :escape_pattern        => /\{\{-([\s\S]+?)\}\}/,
  :interpolation_with_subtemplate_pattern => %r{
    \{\{=(?<start>(?:(?!\}\})[\s\S])+\{)\s*\}\}
    (?<middle>
    (
      (?<re>
        \{\{=?(?:(?!\}\})[\s\S])+\{\s*\}\}
        (?:
          \{\{\s*\}(?:(?!\{\s*\}\})[\s\S])+\{\s*\}\}
          |
          \g<re>
          |
          .{1}
        )*?
        \{\{\s*\}[^\{]+?\}\}
      )
      |
      .{1}
    )*?
    )
    \{\{\s*(?<end>\}[\s\S]+?)\}\}
  }xm
}

QUESTION_MARK_SYNTAX = {
  :evaluation_pattern    => /<\?([\s\S]+?)\?>/,
  :interpolation_pattern => /<\?=([\s\S]+?)\?>/,
  :escape_pattern        => /<\?-([\s\S]+?)\?>/,
  :interpolation_with_subtemplate_pattern => %r{
    <\?=(?<start>(?:(?!\?>)[\s\S])+\{)\s*\?>
    (?<middle>
    (
      (?<re>
        <\?=?(?:(?!\?>)[\s\S])+\{\s*\?>
        (?:
          <\?\s*\}(?:(?!\{\s*\?>)[\s\S])+\{\s*\?>
          |
          \g<re>
          |
          .{1}
        )*?
        <\?\s*\}[^\{]+?\?>
      )
      |
      .{1}
    )*?
    )
    <\?\s*(?<end>\}[\s\S]+?)\?>
  }xm

}

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

# File 'lib/active_support/testing/declarative.rb', somewhere in rails....
class Minitest::Test
  def self.test(name, &block)
    test_name = "test_#{name.gsub(/\s+/,'_')}".to_sym
    defined = instance_method(test_name) rescue false
    raise "#{test_name} is already defined in #{self}" if defined
    if block_given?
      define_method(test_name, &block)
    else
      define_method(test_name) do
        flunk "No implementation provided for #{name}"
      end
    end
  end

  # test/unit backwards compatibility methods
  alias :assert_raise :assert_raises
  alias :assert_not_empty :refute_empty
  alias :assert_not_equal :refute_equal
  alias :assert_not_in_delta :refute_in_delta
  alias :assert_not_in_epsilon :refute_in_epsilon
  alias :assert_not_includes :refute_includes
  alias :assert_not_instance_of :refute_instance_of
  alias :assert_not_kind_of :refute_kind_of
  alias :assert_no_match :refute_match
  alias :assert_not_nil :refute_nil
  alias :assert_not_operator :refute_operator
  alias :assert_not_predicate :refute_predicate
  alias :assert_not_respond_to :refute_respond_to
  alias :assert_not_same :refute_same

  # Fails if the block raises an exception.
  #
  #   assert_nothing_raised do
  #     ...
  #   end
  def assert_nothing_raised(*args)
    yield
  end
    
end