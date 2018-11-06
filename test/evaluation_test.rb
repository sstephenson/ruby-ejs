require 'test_helper'

class EvaluationTest < Minitest::Test

  test "quotes" do
    template = "<%= thing %> is gettin' on my noives!"
    assert_equal "This is gettin' on my noives!", EJS.evaluate(template, thing: "This")
  end

  test "backslashes" do
    template = "<%= thing %> is \\ridanculous"
    assert_equal "This is \\ridanculous", EJS.evaluate(template, thing: "This")
  end

  test "backslashes into interpolation" do
    template = %q{<%- "Hello \"World\"" %>}
    assert_equal 'Hello "World"', EJS.evaluate(template)
  end

  test "implicit semicolon" do
    template = "<% var foo = 'bar' %>"
    assert_equal '', EJS.evaluate(template)
  end

  test "iteration" do
    template = "<ul><%
      for (var i = 0; i < people.length; i++) {
    %><li><%= people[i] %></li><% } %></ul>"
    result = EJS.evaluate(template, people: %w[Moe Larry Curly])
    assert_equal "<ul><li>Moe</li><li>Larry</li><li>Curly</li></ul>", result
  end

  test "without interpolation" do
    template = "<div><p>Just some text. Hey, I know this is silly but it aids consistency.</p></div>"
    assert_equal template, EJS.evaluate(template)
  end

  test "two quotes" do
    template = "It's its, not it's"
    assert_equal template, EJS.evaluate(template)
  end

  test "quote in statement and body" do
    template = "<%
      if(foo == 'bar'){
    %>Statement quotes and 'quotes'.<% } %>"
    assert_equal "Statement quotes and 'quotes'.", EJS.evaluate(template, :foo => "bar")
  end

  test "newlines and tabs" do
    template = "This\n\t\tis: <%= x %>.\n\tok.\nend."
    assert_equal "This\n\t\tis: that.\n\tok.\nend.", EJS.evaluate(template, :x => "that")
  end

  test "escaping" do
    template = "<%= foobar %>"
    assert_equal "&#60;b&#62;Foo Bar&#60;&#47;b&#62;", EJS.evaluate(template, foobar: "<b>Foo Bar</b>")

    template = "<%= foobar %>"
    assert_equal "Foo &#38; Bar", EJS.evaluate(template, { :foobar => "Foo & Bar" })

    template = "<%= foobar %>"
    assert_equal "&#34;Foo Bar&#34;", EJS.evaluate(template, { :foobar => '"Foo Bar"' })

    template = "<%= foobar %>"
    assert_equal "&#39;Foo Bar&#39;", EJS.evaluate(template, { :foobar => "'Foo Bar'" })
  end

end