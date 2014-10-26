require 'test_helper'

class CustomPatternTest < Minitest::Test

  def setup
    @original_evaluation_pattern = EJS.evaluation_pattern
    @original_interpolation_pattern = EJS.interpolation_pattern
    EJS.evaluation_pattern = BRACE_SYNTAX[:evaluation_pattern]
    EJS.interpolation_pattern = BRACE_SYNTAX[:interpolation_pattern]
  end

  def teardown
    EJS.interpolation_pattern = @original_interpolation_pattern
    EJS.evaluation_pattern = @original_evaluation_pattern
  end

  test "compile" do
    result = EJS.compile("Hello {{= name }}")
    assert_match FUNCTION_PATTERN, result
    assert_no_match(/Hello \{\{= name \}\}/, result)
  end

  test "compile with custom syntax" do
    standard_result = EJS.compile("Hello {{= name }}")
    question_result = EJS.compile("Hello <?= name ?>", QUESTION_MARK_SYNTAX)

    assert_match FUNCTION_PATTERN, question_result
    assert_equal standard_result, question_result
  end
end
