require 'test_helper'

class CustomPatternTest < Minitest::Test

  test "compile with custom defults" do
    old_defaults = EJS::DEFAULTS
    EJS::DEFAULTS = {
      open_tag: '{{',
      close_tag: '}}',
  
      open_tag_modifiers: {
        escape: '=',
        unescape: '-',
        comment: '#',
        literal: '%'
      },

      close_tag_modifiers: {
        trim: '-',
        literal: '%'
      },
  
      escape: nil
    }

    result = EJS.compile("Hello {{= name }}")
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
  ensure
    EJS::DEFAULTS = old_defaults
  end

  test "compile with custom syntax" do
    standard_result = EJS.compile("Hello <%= name %>")
    question_result = EJS.compile("Hello <?= name ?>", open_tag: '<?', close_tag: '?>')
    assert_equal standard_result, question_result
  end
end