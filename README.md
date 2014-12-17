EJS (Embedded JavaScript) template compiler for Ruby [![Circle CI](https://circleci.com/gh/malomalo/ruby-ejs.svg?style=svg)](https://circleci.com/gh/malomalo/ruby-ejs)
====================================================

EJS templates embed JavaScript code inside `<% ... %>` tags, much like
ERB. This library is a port of
[Underscore.js](http://documentcloud.github.com/underscore/)'s
[`_.template`
function](http://documentcloud.github.com/underscore/#template) to
Ruby, and strives to maintain the same syntax and semantics.

Pass an EJS template to `EJS.compile` to generate a JavaScript
function:

    EJS.compile("Hello <%= name %>")
    # => "function(obj){...}"

Invoke the function in a JavaScript environment to produce a string
value. You can pass an optional object specifying local variables for
template evaluation.

The EJS tag syntax is as follows:

* `<% ... %>` silently evaluates the statement inside the tags.
* `<%= ... %>` evaluates the expression inside the tags and inserts
  its string value into the template output.
* `<%- ... %>` behaves like `<%= ... %>` but HTML-escapes its output.

If a evalation tag (`<%=`) ends with an open function, the function
return a compiled template. For example:

```erb
<% formTag = function(template) { return '<form>\n'+template()+'\n</form>'; } %>

<%= formTag(function () { %>
  <input type="submit" />
<% }) %>
```

generates:

```html
<form>
  <input type="submit" />
</form>
```

If you have the [ExecJS](https://github.com/sstephenson/execjs/)
library and a suitable JavaScript runtime installed, you can pass a
template and an optional hash of local variables to `EJS.evaluate`:

    EJS.evaluate("Hello <%= name %>", :name => "world")
    # => "Hello world"

-----

&copy; 2012 Sam Stephenson

Released under the MIT license
