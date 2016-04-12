# encoding: utf-8
#
# This file is part of MarkUS.
#
# MarkUS is free software: you can redistribute it and/or modify it under the terms
# of the GNU General Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# MarkUS is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# MarkUS (file COPYING in the main directory).  If not, see
# <http://www.gnu.org/licenses/>.

# Markup UnderScore
# ----   -    -

require 'escape_utils'

class MarkUS
  class << self
    attr_accessor :__markus_reload
    attr_accessor :__markus_reload_timestamp
    attr_accessor :__markus_file
    attr_accessor :__markus_templates
    attr_accessor :__markus_indent
    attr_accessor :__markus_includes
  end

  class MarkUSString < String; end

  attr_reader :__markus_indent, :__markus_reload
  def __markus_indent=(value) #{{{
    self.class.__markus_indent = value == true ? true : false
  end #}}}
  def __markus_reload=(value) #{{{
    self.class.__markus_reload = value == true ? true : false
  end #}}}

  def json_!(name,params={}) #{{{
    markus_! name, :json, params
  end #}}}
  def xml_!(name,params={}) #{{{
    markus_! name, :xml, params
  end #}}}
  def html_!(name,params={}) #{{{
    markus_! name, :html, params
  end #}}}

  def markus_!(name,type,params={}) #{{{
    @__markus = []
    @__markus_buffer = []
    @__markus_level = -1
    @__markus_parent = nil

    params.each do |k,v|
      self.instance_variable_set(("@" + k.to_s).to_sym, v)
    end if params.is_a? Hash

    self.class.__markus_do_reload
    self.class.__markus_includes.each do |some|
      if some.__markus_do_reload
        self.class.__markus_templates.merge! some.__markus_templates
      end
    end
    @__markus_mode = type

    template_!(name)
    @__markus_buffer.last.chomp!(',') if @__markus_mode == :json
    self.class.__markus_indent ? @__markus_buffer.join("\n") : @__markus_buffer.join
  end
 #}}}

  def element_!(name=nil, *args, &blk) #{{{
    __markus_method_missing name, *args, &blk
  end #}}}
  def value_!(val) #{{{
    case val
      when String
        content = "\"#{val.gsub(/"/,'\\\"')}\""
      when Integer, Float
        content = val
      else
        content = "null"
    end
    @__markus_level += 1
    if self.class.__markus_indent
      @__markus_buffer << "#{"  " * @__markus_level}#{content},"
    else
      @__markus_buffer << "#{content},"
    end
    @__markus_level -= 1
    nil
  end #}}}
  def template_!(name,*args) #{{{
    instance_exec *args, &self.class.__markus_templates[name]
  end #}}}

  def __markus_indent(lvl=0) #{{{
    self.class.__markus_indent ? "#{"  " * (@__markus_level + lvl)}" : ""
  end #}}}

  def method_missing(name,*args, &blk) #{{{ # :nodoc:
    if name.to_s =~ /(.*)(__)$/ || name.to_s =~ /(.*)(_)$/
      __markus_method_missing $1, *args, &blk
    else
      super
    end
  end #}}}
  def __markus_method_missing(name,*args, &blk) #{{{ # :nodoc:
    case @__markus_mode
      when :json
        __markus_json name, *args, &blk
      else
        __markus_xml name, *args, &blk
    end
  end #}}}
  def __markus_xml(tname,*args) #{{{ # :nodoc:
    attrs = ""
    content = nil
    args.each do |a|
      case a
        when Hash
          attrs << " " + a.collect { |key,value|
            value.nil? ? nil : "#{key}=\"#{value.to_s.gsub(/"/,"&#34;")}\""
          }.compact.join(" ")
          attrs = '' if attrs == ' '
        when String
          content = EscapeUtils.escape_html(a)
        when Integer
          content = a
      end
    end
    @__markus_level += 1
    if block_given?
      @__markus_buffer << __markus_indent + "<#{tname}#{attrs}>"
      @__markus_buffer << __markus_indent(1) + "#{content}" unless content.nil?
      res = yield
      @__markus_buffer << res if String === res
      @__markus_buffer << __markus_indent + "</#{tname}>"
    else
      if @__markus_mode == :xml && content.nil?
        @__markus_buffer << __markus_indent + "<#{tname}#{attrs}/>"
      else
        @__markus_buffer << __markus_indent + "<#{tname}#{attrs}>#{content}</#{tname}>"
      end
    end
    @__markus_level -= 1
  end #}}}
  def __markus_json(tname,*args,&blk) #{{{ # :nodoc:
    attrs = content = nil
    args.each do |a|
      case a
        when Array
          attrs = "[ " + a.collect { |value|
            case value
              when Integer, Float
                value.nil? ? nil : value.to_s
              else
                value.nil? ? nil : "\"#{value.to_s.gsub(/"/,'\\\"')}\""
            end
          }.compact.join(", ").strip + " ]"
          attrs = '[]' if attrs == "[  ]"
        when Hash
          attrs = "{ " + a.collect { |key,value|
            case value
              when Integer, Float
                value.nil? ? nil : "\"#{key}\": #{value}"
              else
                value.nil? ? nil : "\"#{key}\": \"#{value.to_s.gsub(/"/,'\\\"')}\""
            end
          }.compact.join(", ").strip + " }"
          attrs = '{}' if attrs == "{  }"
        when String
          content = a.class == ::MarkUS::MarkUSString ? a : "\"#{a.gsub(/"/,'\\\"')}\""
        when Integer, Float
          content = a
        else
          content = "\"#{a.to_s}\""
      end
    end

    @__markus_level += 1
    mpsic = @__markus_parent

    if mpsic == :a && !tname.nil?
      @__markus_buffer << __markus_indent + "{"
    end  

    if [content, attrs, blk].compact.length > 1
      @__markus_parent = nil

      @__markus_buffer << __markus_indent + "\"#{tname}\": {"
      __markus_json "attributes", ::MarkUS::MarkUSString.new(attrs) if attrs
      __markus_json "value", ::MarkUS::MarkUSString.new(content) if content
      __markus_json "content", &blk if blk
      @__markus_buffer.last.chomp!(',')
      @__markus_buffer << __markus_indent + "},"
    else
      if blk
        if mpsic == :a && !tname.nil?
          @__markus_parent = nil
          __markus_json tname, *args, &blk
        else
          @__markus_parent = type = blk.parameters.length == 1 && blk.parameters[0][1] == :array ? :a : :h
          @__markus_buffer << __markus_indent + "#{tname.nil? ? '' : "\"#{tname}\": "}#{type == :a ? '[' : '{'}"

          c1 = @__markus_buffer.length
          res = blk.call
          c2 = @__markus_buffer.length
          if c1 == c2
            @__markus_buffer.last << "#{type == :a ? ']' : '}'},"
          else
            @__markus_buffer << res + ',' if type == :a && res.is_a?(String)
            @__markus_buffer.last.chomp!(',')
            @__markus_buffer << __markus_indent + "#{type == :a ? ']' : '}'},"
          end
        end
      else  
        @__markus_buffer << __markus_indent + "\"#{tname}\": #{attrs || content},"
      end  
    end

    if mpsic == :a && !tname.nil?
      @__markus_buffer.last.chomp!(',')
      @__markus_buffer << __markus_indent + "},"
    end

    @__markus_level -= 1
    @__markus_parent = mpsic
  end #}}}

  def self::inherited(subclass) #{{{ # :nodoc:
    subclass.instance_eval do |i|
      # This array contains strings like "/path/to/a.rb:3:in `instance_eval'".
      strings_ary = caller

      # We look for the last string containing "<top (required)>".
      # only works in > 1.9
      val = "<top (required)>"
      until require_index = strings_ary.index {|x| x.include?(val) }
        val = "<main>"
      end
      require_string = strings_ary[require_index]
      filepath = File.expand_path(require_string[/^(.*):\d+:in/, 1])


      # We use a regex to extract the filepath from require_string. Other defaults.
      self.__markus_reload           = false
      self.__markus_reload_timestamp = nil
      self.__markus_file             = filepath
      self.__markus_templates        = {}
      self.__markus_indent           = self.class_variable_defined?(:@@__markus_indent) ? @@__markus_indent : false
      self.__markus_includes         = []
    end
  end #}}}

  def  self::reload #{{{
    self.__markus_reload = true
    self.__markus_reload_timestamp = File.stat(self.__markus_file).mtime
  end #}}}
  def self:: __markus_do_reload  #{{{ # :nodoc:
    if self.__markus_reload && self.__markus_reload_timestamp
      if File.stat(self.__markus_file).mtime > self.__markus_reload_timestamp
        load self.__markus_file
        return true
      end
    end
    false
  end #}}}

  def self::template(name,&p) #{{{
    self.__markus_templates ||= {}
    self.__markus_templates[name] = p
  end #}}}
  def self::indent #{{{
    if self.__markus_indent.nil?
      @@__markus_indent = true
    else
      self.__markus_indent = true
    end
  end #}}}

  def self::templates(some)
    self.__markus_includes << some
    self.__markus_templates.merge! some.__markus_templates
  end
end
