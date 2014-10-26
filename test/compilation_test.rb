require 'test_helper'

class CompilationTest < Minitest::Test
  
  test "compile" do
    result = EJS.compile("Hello <%= name %>")
    
    assert_match FUNCTION_PATTERN, result
    assert_no_match(/Hello \<%= name %\>/, result)
  end

  test "compile with custom syntax" do
    standard_result = EJS.compile("Hello <%= name %>")
    braced_result   = EJS.compile("Hello {{= name }}", BRACE_SYNTAX)

    assert_match FUNCTION_PATTERN, braced_result
    assert_equal standard_result, braced_result
  end
  
end
