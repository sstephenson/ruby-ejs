require 'test_helper'

class SubtemplateTest < Minitest::Test

  test "quotes" do
    template = <<-DATA
      <% formTag = function(template) { return '<form>\\n'+template()+'\\n</form>'; } %>

      <%= formTag(function () { %>
        <input type="submit" />
      <% }) %>
    DATA
    
    assert_equal <<-DATA, EJS.evaluate(template)
      

      <form>

        <input type=\"submit\" />
      
</form>
    DATA
  end
  
end