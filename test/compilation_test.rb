require 'test_helper'

class CompilationTest < Minitest::Test
  
  test "compile" do
    result = EJS.compile("Hello <%= name %>")
    
    assert_match FUNCTION_PATTERN, result
    assert_no_match(/Hello \<%= name %\>/, result)
    assert_equal(<<~JS.strip, result)
      function(locals, escape) {
          var __output = [], __append = __output.push.bind(__output);
          with (locals || {}) {
              __append(`Hello `);
              __append(escape( name ));
          }
          return __output.join("");
      }
    JS
  end
  
end
