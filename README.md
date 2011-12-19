EJS (Embedded JavaScript) template compiler for Ruby
====================================================

EJS templates embed JavaScript code inside `<% ... %>` tags, much like
ERB. This library is a port of
[Underscore.js](http://documentcloud.github.com/underscore/)'s
[`_.template`
function](http://documentcloud.github.com/underscore/#template) to
Ruby.

Pass an EJS template to `EJS.compile` to generate a JavaScript
function:

    EJS.compile("Hello <%= name %>")
    # => "function(obj){...}"

Using the default syntax `<%= content %>`, content is escaped, à la Rails 3. For unescaped content, use the unescaped syntax `<%: content %>`.

    EJS.compile("Hello <%: name %>")
    # => "function(obj){...}"
    
About the js escape function : 

By default, js is escaped using a function injected in **each** template. To avoid that, save some kb and be more DRY, you can specify your own escape function :

    # Example : to use underscore.js escape function, put this in an initializer file (ex. config/initializers/ejs.rb)
    EJS.escape_function_name = '_.escape'


Invoke the function in a JavaScript environment to produce a string
value. You can pass an optional object specifying local variables for
template evaluation.

If you have the [ExecJS](https://github.com/sstephenson/execjs/)
library and a suitable JavaScript runtime installed, you can pass a
template and an optional hash of local variables to `EJS.evaluate`:

    EJS.evaluate("Hello <%= name %>", :name => "world")
    # => "Hello world"

-----

&copy; 2011 Sam Stephenson

Released under the MIT license
