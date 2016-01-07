== Markup UnderScore

Copyright (C) 2004-2007 Jürgen Mangler <juergen.mangler@univie.ac.at>

MarkUS is freely distributable according to the terms of the
GNU Lesser General Public License (see the file 'COPYING').

This program is distributed without any warranty. See the file
'COPYING' for details.

== Introduction

All template libraries suck. But sometimes they are useful, for building
quick'n dirty creation of documents. This template library will of course suck
as well. It is inspired by _why's markaby. It supports JSON and XML.

== HTML Example Template

    html_ do
      body_ :class => 'test' do
        a_ 'Ruby', :href => 'https://ruby-lang.org' 
        span_ do
          'Some Text'                                                                                                                                        
        end
      end
    end

== JSON Example Template

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

Why the f**k would i use a template library for JSON when i can just create a
big hash, and create a json out of it? If you ever find yourself feeling bad or
lost with your big hashes, try this out. Maybe you like it, maybe not. Who
knows.

== Installation

* You need a least ruby 1.9.2

== Documentation

View the examples in the ./examples subdirectory.
