module EJS

  DEFAULTS = {
    open_tag: '<%',
    close_tag: '%>',
    
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
  
  ASSET_DIR = File.join(__dir__, 'ruby', 'ejs', 'assets')
  
  class << self
    
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
    def transform(source, options = {})
      options = default(options)
      
      output = if options[:escape]
        "import {" + options[:escape].split('.').reverse.join(" as escape} from '") + "';\n"
      else
        "import {escape} from 'ejs';\n"
      end
      
      fs = function_source(source, options)
      output << fs[1]
      output << "export default function (locals) {\n"
      output << fs[0]
      output << "}"

      output
    end

    def compile(source, options = {})
      options = default(options)
      
      output = "function(locals, escape) {\n"
      output << function_source(source, options)[0]
      output << "}"
      output
    end


    # Evaluates an EJS template with the given local variables and
    # compiler options. You will need the ExecJS
    # (https://github.com/sstephenson/execjs/) library and a
    # JavaScript runtime available.
    #
    #     EJS.evaluate("Hello <%= name %>", name: "world")
    #     # => "Hello world"
    #
    def evaluate(template, locals = {}, options = {})
      require "execjs"
      context = ExecJS.compile(<<-JS)
        #{escape_function}
        
        var template = #{compile(template, options)}
        var evaluate = function(locals) {
          return template(locals, escape);
        }
      JS
      context.call("evaluate", locals)
    end

    protected
    
      def default(options)
        options = DEFAULTS.merge(options)
      
        [:open_tag_modifiers, :close_tag_modifiers].each do |k|
          DEFAULTS[k].each do |sk, v|
            next if options[k].has_key?(sk)
            options[k] = v
          end
        end
      
        options
      end

      def escape_module
        escape_function.sub('function', 'export function')
      end

      def escape_function(name='escape')
        <<-JS
          function #{name}(string) {
            if (string !== undefined && string != null) {
              return String(string).replace(/[&<>'"\\/]/g, function (c) {
                return '&#' + c.codePointAt(0) + ';';
              });
            } else {
              return '';
            }
          }
        JS
      end
      
      def chars_balanced?(str, chars)
        a = chars[0]
        b = chars[1]
        str = str.sub(/"(\\.|[^"])+"/, '')
        str = str.sub(/'(\\.|[^'])+'/, '')
        a_count = str.scan(/#{a}/).length
        b_count = str.scan(/#{b}/).length
      
        a_count - b_count
      end
    

      def digest(source, options)
        open_tag_count = 0
        close_tag_count = 0
        tag_length = nil
        # var index, tagType, tagModifier, tagModifiers, matchingModifier, prefix;
        index = nil
        tag_type = nil
        tag_modifiers = nil
        tag_modifier = nil
        prefix =nil
        matching_modifier = nil
        last_tag_modifier = nil
        next_open_index = source.index(options[:open_tag])
        next_close_index = source.index(options[:close_tag])
  
        while next_open_index || next_close_index
          if (next_close_index && (!next_open_index || next_close_index < next_open_index))
            index = next_close_index
            tag_type = :close
            tag_length = options[:close_tag].length
            tag_modifiers = options[:close_tag_modifiers]
            close_tag_count += 1
            matching_modifier = tag_modifiers.find do |k, v|
              source[index - v.length, v.length] == v
            end
          else
            index = next_open_index
            tag_type = :open
            tag_length = options[:open_tag].length
            tag_modifiers = options[:open_tag_modifiers]
            open_tag_count += 1
            matching_modifier = tag_modifiers.find do |k, v|
              source[index + tag_length, v.length] == v
            end
          end

          if matching_modifier
            tag_length += matching_modifier[1].length
            tag_modifier = matching_modifier[0]
          else
            tag_modifier = :default
          end

          if tag_modifier == :literal
            if tag_type == :open
              source = source[0, tag_length - matching_modifier[1].length] + source[(index + tag_length)..-1]
              # source = source.slice(0, index + tagLength - matchingModifier[1].length) + source.slice(index + tagLength);
              open_tag_count -= 1
            else
              close_tag_count -= 1
              if index == 0
                source = source[(index + matching_modifier[1].length)..-1]
              else
                source = source[0..index] + source[(index + matching_modifier[1].length)..-1]
              end
            end

            next_open_index = source.index(options.openTag, index + tag_length - matching_modifier[1].length);
            next_close_index = source.index(options.closeTag, index + tag_length - matching_modifier[1].length);
            next
          end
    
          if index != 0
            if tag_type == :close
              if matching_modifier
                yield(source[0...(matching_modifier[1].length)], :js, last_tag_modifier)
              else
                yield(source[0...index], :js, last_tag_modifier)
              end
            else
              yield(source[0...index], :text, last_tag_modifier)
            end
      
            source = source[index..-1]
          end

          if tag_type == :close && matching_modifier
            source = source[(tag_length - matching_modifier[1].length)..-1]
            source.lstrip!
          else
            source = source[tag_length..-1]
          end
          next_open_index = source.index(options[:open_tag])
          next_close_index = source.index(options[:close_tag])
          last_tag_modifier = tag_modifier
        end
      
        if open_tag_count != close_tag_count
          raise "Could not find closing tag for \"#{options[(tag_type.to_s + '_tag').to_sym]}\"."
        end
  
        yield(source, :text, tag_modifier)
      end


      def function_source(source, options)
        stack = []
        imports = ""
        output =  "    var __output = [], __append = __output.push.bind(__output);\n"
        output << "    with (locals || {}) {\n" unless options[:strict]

        digest(source, options) do |segment, type, modifier|
          if type == :js
            if segment.match(/\A\s*\}/m)
              case stack.pop
              when :escape
                output << "\n            return __output.join(\"\");\n"
                output << segment << "        ));\n"
              when :unescape
                output << "\n            return __output.join(\"\");\n"
                output << segment << "        );\n"
              else
                output << "        " << segment << "\n"
              end
            elsif segment.match(/\)\s*\{\s*\Z/m)
              stack << modifier
              case modifier
              when :escape
                output << "        __append(escape(" << segment
                output << "\n            var __output = [], __append = __output.push.bind(__output);\n"
              when :unescape
                output << "        __append(" << segment
                output << "\n            var __output = [], __append = __output.push.bind(__output);\n"
              else
                output << "        " << segment << "\n"
              end
            else
              case modifier
              when :escape
                output << "        __append(escape(" << segment << "));\n"
              when :unescape
                output << "        __append(" << segment << ");\n"
              else
                if segment =~ /\A\s*import/
                  imports << segment.strip
                  imports << ';' unless segment =~ /;\s*\Z/
                  imports << "\n"
                else
                  output << "        " << segment << "\n"
                end
              end
            end
          elsif segment.length > 0
            output << "        __append(`" + segment.gsub("\\"){"\\\\"}.gsub(/\n/, '\\n').gsub(/\r/, '\\r') + "`);\n"
          end
        end

        output << "    }\n" unless options[:strict]
        output << "    return __output.join(\"\");\n"
        imports << "\n"
        
        [output, imports]
      end
      
  end
end
