# Markup UnderScore

Copyright (C) 2004-2016 Jürgen "eTM" Mangler <juergen.mangler@gmail.com>

MarkUS is freely distributable according to the terms of the
GNU Lesser General Public License 3.0 (see the file 'COPYING').

This code is distributed without any warranty. See the file
'COPYING' for details.

## Introduction

All template libraries suck. But sometimes they are useful, for 
quick n' dirty building of documents. This template library will of course suck
as well. It is inspired by _why's markaby. It supports JSON and XML.

## Usage - Jump Start

Its fairly simple:

1. Create classes that inherit from MarkUS, and add templates with a name to them (see below). 
2. In the templates use arbitrary code, mixed with functions that have an _ at the end. 
3. Everything with an _ at the end is added to the result buffer
  - If the first parameter is a String or Integer it will be used as content of the element
  - If any parameter is a Hash it will be used as attributes in XML, or you-know-what in JSON
  - If any parameter is an Array it will be used as you-know-what in JSON
  - If it has a block, a nested data structure is implied (see template examples below)
  - JSON only: by default a Hash is assumed, if you pass a paramter `array`, e.g. `value_ do |array| ... end`, the result is `"value": [ ... ]`
  - `#template_!` is a special method to include other templates
  - `#element_!` allows you to include stuff in your result that is not a valid ruby function name (e.g. with a dot in the name - see below)
4. Get the result by instantiating the class and calling one of `#json_!`, `#xml_!`, `#html_!`
  - `#xml_!` and `#html_!` differ in the way elements with no content are printed. XML uses short-handed tags, HTML doesn't.

`#json_!`, `#xml_!` and `#html_!` need the name of the template as
the first parameter, optional you can pass a hash. All pairs in the hash are
available as instance variables. Of course you can also handle it yourself through a
constructor in the template class.

## Usage - Example

template1.rb:
```ruby
class Common < MarkUS
  template :test1 do
    query_ [2, 3, @w]
  end
  template :test2 do
    query_ :a => 2, :b => @h
  end
end
```

template2.rb:
```ruby
require File.expand_path(File.dirname(__FILE__) + '/template1')

class Something < MarkUS
  templates Common                                                                                                                                                                                                                                                   

  indent

  template :main do
    template_! :test1
    template_! :test2
  end
end
```

main.rb:
```ruby
  require 'markus'
  require File.expand_path(File.dirname(__FILE__) + '/template2')
  s = Something.new
  result = s.json_! :main, :h => 'hello', :w => 'world'
  puts result
```

If you add `reload` to any of the template classes, they will be reloaded if they change (if templates are use in a long-running service).



## HTML Example Template

```ruby
html_ do
  body_ :class => 'test' do
    a_ 'Ruby', :href => 'https://ruby-lang.org'
    span_ do
      'Some Text'
    end
  end
end
```

## JSON Example Template

```ruby
query_ do
  filtered_ do
    filter_ do
      bool_ do
        must_ do |array|
          nested_ do
            path_ "contact"
            query_ do
              term_ do
                element_! "contact.durchwahl", 1
              end
            end
          end
        end
      end
    end
  end
end
```

Why the f**k would i use a template library for JSON when i can just create a
big hash or array and create a json out of it? If you ever find yourself feeling bad or
lost with your big hashes, try this out. Maybe you like it, maybe not. Who
knows.

## Installation

* You need a least ruby 1.9.2

## Further Reading

View the example in the ./examples subdirectory. View the tests in the ./test subdirectory. From there you should be able to figure it out yourself. Tip: neat combinations with heredocs are possible, e.g. to create script tags in html.

```ruby
  script_ <<~end
    var foo = "bar";
  end
```

