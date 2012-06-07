# EJS (Embedded JavaScript) template compiler for Ruby
# This is a port of Underscore.js' `_.template` function:
# http://documentcloud.github.com/underscore/

module EJS
  JS_UNESCAPES = {
    '\\' => '\\',
    "'" => "'",
    'r' => "\r",
    'n' => "\n",
    't' => "\t",
    'u2028' => "\u2028",
    'u2029' => "\u2029"
  }
  JS_ESCAPES = JS_UNESCAPES.invert
  JS_UNESCAPE_PATTERN = /\\(#{Regexp.union(JS_UNESCAPES.keys)})/
  JS_ESCAPE_PATTERN = Regexp.union(JS_ESCAPES.keys)

  class << self
    attr_accessor :evaluation_pattern
    attr_accessor :interpolation_pattern
    attr_accessor :escape_pattern

    # Compiles an EJS template to a JavaScript function. The compiled
    # function takes an optional argument, an object specifying local
    # variables in the template.  You can optionally pass the
    # `:evaluation_pattern` and `:interpolation_pattern` options to
    # `compile` if you want to specify a different tag syntax for the
    # template.
    #
    #     EJS.compile("Hello <%= name %>")
    #     # => "function(obj){...}"
    #
    def compile(source, options = {})
      source = source.dup

      js_escape!(source)
      replace_escape_tags!(source, options)
      replace_interpolation_tags!(source, options)
      replace_evaluation_tags!(source, options)
      "function(obj){var __p=[],print=function(){__p.push.apply(__p,arguments);};" +
        "with(obj||{}){__p.push('#{source}');}return __p.join('');}"
    end

    # Evaluates an EJS template with the given local variables and
    # compiler options. You will need the ExecJS
    # (https://github.com/sstephenson/execjs/) library and a
    # JavaScript runtime available.
    #
    #     EJS.evaluate("Hello <%= name %>", :name => "world")
    #     # => "Hello world"
    #
    def evaluate(template, locals = {}, options = {})
      require "execjs"
      context = ExecJS.compile("var evaluate = #{compile(template, options)}")
      context.call("evaluate", locals)
    end

    protected
      def js_escape!(source)
        source.gsub!(JS_ESCAPE_PATTERN) { |match| '\\' + JS_ESCAPES[match] }
        source
      end

      def js_unescape!(source)
        source.gsub!(JS_UNESCAPE_PATTERN) { |match| JS_UNESCAPES[match[1..-1]] }
        source
      end

      def replace_escape_tags!(source, options)
        source.gsub!(options[:escape_pattern] || escape_pattern) do
          "',(''+#{js_unescape!($1)})#{escape_function},'"
        end
      end

      def replace_evaluation_tags!(source, options)
        source.gsub!(options[:evaluation_pattern] || evaluation_pattern) do
          "'); #{js_unescape!($1)}; __p.push('"
        end
      end

      def replace_interpolation_tags!(source, options)
        source.gsub!(options[:interpolation_pattern] || interpolation_pattern) do
          "', #{js_unescape!($1)},'"
        end
      end

      def escape_function
        ".replace(/&/g, '&amp;')" +
        ".replace(/</g, '&lt;')" +
        ".replace(/>/g, '&gt;')" +
        ".replace(/\"/g, '&quot;')" +
        ".replace(/'/g, '&#x27;')" +
        ".replace(/\\//g,'&#x2F;')"
      end
  end

  self.evaluation_pattern = /<%([\s\S]+?)%>/
  self.interpolation_pattern = /<%=([\s\S]+?)%>/
  self.escape_pattern = /<%-([\s\S]+?)%>/
end
