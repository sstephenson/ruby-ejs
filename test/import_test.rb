require 'test_helper'

class ImportTest < Minitest::Test

  test "quotes" do
    template = <<-DATA
      <% import x from y %>
      <% import a from z %>
      
      <% formTag = function(template) { return '<form>\\n'+template()+'\\n</form>'; } %>

      <%- formTag(function () { %>
        <input type="submit" />
      <% }) %>
    DATA

    assert_equal <<~DATA.strip, EJS.transform(template)
    import {escape} from 'ejs';
    import x from y;
    import a from z;

    export default function (locals) {
        var __output = [], __append = __output.push.bind(__output);
        with (locals || {}) {
            __append(`      `);
            __append(`\\n      `);
            __append(`\\n      \\n      `);
             formTag = function(template) { return '<form>\\n'+template()+'\\n</form>'; } 
            __append(`\\n\\n      `);
            __append( formTag(function () { 
                var __output = [], __append = __output.push.bind(__output);
            __append(`\\n        <input type="submit" />\\n      `);

                return __output.join("");
     })         );
            __append(`\\n`);
        }
        return __output.join("");
    }
    DATA
  end
  
end