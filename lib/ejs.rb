# EJS (Embedded JavaScript) template compiler for Ruby
# (c) 2011 Sam Stephenson
#
# This is a port of Underscore.js' `_.template` function:
# http://documentcloud.github.com/underscore/

module EJS
  DEFAULT_ESCAPE_FUNCTION_NAME = '__e'.freeze
  DEFAULT_ESCAPE_FUNCTION = "#{DEFAULT_ESCAPE_FUNCTION_NAME}=function(s){" +
      "return ((s==null?'':s)+'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');}".freeze

  class << self
    attr_accessor :evaluation_pattern
    attr_accessor :interpolation_pattern
    attr_accessor :interpolation_safe_pattern
    attr_accessor :escape_function_name

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

      escape_quotes!(source)
      replace_interpolation_safe_tags!(source, options)
      replace_interpolation_tags!(source, options)
      replace_evaluation_tags!(source, options)
      escape_whitespace!(source)
      "function(obj){var #{escape_function_if_required}" +
        "__p=[],print=function(){__p.push.apply(__p,arguments);};" +
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
      def escape_quotes!(source)
        source.gsub!(/\\/) { '\\\\' }
        source.gsub!(/'/) { "\\'" }
      end

      def replace_evaluation_tags!(source, options)
        source.gsub!(options[:evaluation_pattern] || evaluation_pattern) do
          "');" + $1.gsub(/\\'/, "'").gsub(/[\r\n\t]/, ' ') + "__p.push('"
        end
      end

      def replace_interpolation_safe_tags!(source, options)
        source.gsub!(options[:interpolation_safe_pattern] || interpolation_safe_pattern) do
          "',#{escape_function_name}(" + $1.gsub(/\\'/, "'") + "),'"
        end
      end
      
      def replace_interpolation_tags!(source, options)
        source.gsub!(options[:interpolation_pattern] || interpolation_pattern) do
          "'," + $1.gsub(/\\'/, "'") + ",'"
        end
      end

      def escape_whitespace!(source)
        source.gsub!(/\r/, '\\r')
        source.gsub!(/\n/, '\\n')
        source.gsub!(/\t/, '\\t')
      end

      def escape_function_if_required
        DEFAULT_ESCAPE_FUNCTION + ',' if escape_function_name == DEFAULT_ESCAPE_FUNCTION_NAME
      end
  end

  self.evaluation_pattern = /<%([\s\S]+?)%>/
  self.interpolation_safe_pattern = /<%=([\s\S]+?)%>/
  self.interpolation_pattern = /<%:([\s\S]+?)%>/
  self.escape_function_name = DEFAULT_ESCAPE_FUNCTION_NAME
end
