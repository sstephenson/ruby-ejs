require "ejs"
require "test/unit"

FUNCTION_PATTERN = /^function\s*\(.*?\)\s*\{(.*?)\}$/

BRACE_SYNTAX = {
  :evaluation_pattern    => /\{\{([\s\S]+?)\}\}/,
  :interpolation_pattern => /\{\{=([\s\S]+?)\}\}/,
  :escape_pattern        => /\{\{-([\s\S]+?)\}\}/
}

QUESTION_MARK_SYNTAX = {
  :evaluation_pattern    => /<\?([\s\S]+?)\?>/,
  :interpolation_pattern => /<\?=([\s\S]+?)\?>/,
  :escape_pattern        => /<\?-([\s\S]+?)\?>/
}

module TestHelper
  def test(name, &block)
    define_method("test #{name.inspect}", &block)
  end
end

class EJSCompilationTest < Test::Unit::TestCase
  extend TestHelper

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

class EJSCustomPatternTest < Test::Unit::TestCase
  extend TestHelper

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

class EJSEvaluationTest < Test::Unit::TestCase
  extend TestHelper

  test "quotes" do
    template = "<%= thing %> is gettin' on my noives!"
    assert_equal "This is gettin' on my noives!", EJS.evaluate(template, :thing => "This")
  end

  test "backslashes" do
    template = "<%= thing %> is \\ridanculous"
    assert_equal "This is \\ridanculous", EJS.evaluate(template, :thing => "This")
  end

  test "backslashes into interpolation" do
    template = %q{<%= "Hello \"World\"" %>}
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
    result = EJS.evaluate(template, :people => ["Moe", "Larry", "Curly"])
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


  test "braced iteration" do
    template = "<ul>{{ for (var i = 0; i < people.length; i++) { }}<li>{{= people[i] }}</li>{{ } }}</ul>"
    result = EJS.evaluate(template, { :people => ["Moe", "Larry", "Curly"] }, BRACE_SYNTAX)
    assert_equal "<ul><li>Moe</li><li>Larry</li><li>Curly</li></ul>", result
  end

  test "braced quotes" do
    template = "It's its, not it's"
    assert_equal template, EJS.evaluate(template, {}, BRACE_SYNTAX)
  end

  test "braced quotes in statement and body" do
    template = "{{ if(foo == 'bar'){ }}Statement quotes and 'quotes'.{{ } }}"
    assert_equal "Statement quotes and 'quotes'.", EJS.evaluate(template, { :foo => "bar" }, BRACE_SYNTAX)
  end


  test "question-marked iteration" do
    template = "<ul><? for (var i = 0; i < people.length; i++) { ?><li><?= people[i] ?></li><? } ?></ul>"
    result = EJS.evaluate(template, { :people => ["Moe", "Larry", "Curly"] }, QUESTION_MARK_SYNTAX)
    assert_equal "<ul><li>Moe</li><li>Larry</li><li>Curly</li></ul>", result
  end

  test "question-marked quotes" do
    template = "It's its, not it's"
    assert_equal template, EJS.evaluate(template, {}, QUESTION_MARK_SYNTAX)
  end

  test "question-marked quote in statement and body" do
    template = "<? if(foo == 'bar'){ ?>Statement quotes and 'quotes'.<? } ?>"
    assert_equal "Statement quotes and 'quotes'.", EJS.evaluate(template, { :foo => "bar" }, QUESTION_MARK_SYNTAX)
  end

  test "escaping" do
    template = "<%- foobar %>"
    assert_equal "&lt;b&gt;Foo Bar&lt;&#x2F;b&gt;", EJS.evaluate(template, { :foobar => "<b>Foo Bar</b>" })

    template = "<%- foobar %>"
    assert_equal "Foo &amp; Bar", EJS.evaluate(template, { :foobar => "Foo & Bar" })

    template = "<%- foobar %>"
    assert_equal "&quot;Foo Bar&quot;", EJS.evaluate(template, { :foobar => '"Foo Bar"' })

    template = "<%- foobar %>"
    assert_equal "&#x27;Foo Bar&#x27;", EJS.evaluate(template, { :foobar => "'Foo Bar'" })
  end

  test "braced escaping" do
    template = "{{- foobar }}"
    assert_equal "&lt;b&gt;Foo Bar&lt;&#x2F;b&gt;", EJS.evaluate(template, { :foobar => "<b>Foo Bar</b>" }, BRACE_SYNTAX)

    template = "{{- foobar }}"
    assert_equal "Foo &amp; Bar", EJS.evaluate(template, { :foobar => "Foo & Bar" }, BRACE_SYNTAX)

    template = "{{- foobar }}"
    assert_equal "&quot;Foo Bar&quot;", EJS.evaluate(template, { :foobar => '"Foo Bar"' }, BRACE_SYNTAX)

    template = "{{- foobar }}"
    assert_equal "&#x27;Foo Bar&#x27;", EJS.evaluate(template, { :foobar => "'Foo Bar'" }, BRACE_SYNTAX)
  end

  test "question-mark escaping" do
    template = "<?- foobar ?>"
    assert_equal "&lt;b&gt;Foo Bar&lt;&#x2F;b&gt;", EJS.evaluate(template, { :foobar => "<b>Foo Bar</b>" }, QUESTION_MARK_SYNTAX)

    template = "<?- foobar ?>"
    assert_equal "Foo &amp; Bar", EJS.evaluate(template, { :foobar => "Foo & Bar" }, QUESTION_MARK_SYNTAX)

    template = "<?- foobar ?>"
    assert_equal "&quot;Foo Bar&quot;", EJS.evaluate(template, { :foobar => '"Foo Bar"' }, QUESTION_MARK_SYNTAX)

    template = "<?- foobar ?>"
    assert_equal "&#x27;Foo Bar&#x27;", EJS.evaluate(template, { :foobar => "'Foo Bar'" }, QUESTION_MARK_SYNTAX)
  end
end
