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

class MarkUS
  class << self
    attr_accessor :__markus_reload
    attr_accessor :__markus_reload_timestamp
    attr_accessor :__markus_file
    attr_accessor :__markus_templates
    attr_accessor :__markus_indent
    attr_accessor :__markus_includes
  end

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
    @__markus_buffer.last.chop! if @__markus_mode == :json
    self.class.__markus_indent ? @__markus_buffer.join("\n") : @__markus_buffer.join
  end
 #}}}
 
  def element_!(name=nil, *args, &blk) #{{{
    __markus_method_missing name, *args, &blk
  end #}}}
  def template_!(name) #{{{
    instance_eval &self.class.__markus_templates[name]
  end #}}}

  def method_missing(name,*args, &blk) #{{{ # :nodoc:
    if name.to_s =~ /(.*)(__)$/ || name.to_s =~ /(.*)(_)$/
      __markus_method_missing $1, *args, &blk
    else
      super
    end  
  end #}}}
  def __markus_method_missing(name,*args, &blk) #{{{ # :nodoc:
    if @__markus_mode == :json
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
        when String,Integer
          content = a
      end  
    end
    attrs = '' if attrs == ' '
    if block_given?
      @__markus_level += 1
      if self.class.__markus_indent
        @__markus_buffer << "#{"  " * @__markus_level}<#{tname}#{attrs}>"
      else  
        @__markus_buffer << "<#{tname}#{attrs}>"
      end  
      unless content.nil?
        if self.class.__markus_indent
          @__markus_buffer << "#{"  " * (@__markus_level+1)}#{content}"
        else
          @__markus_buffer << "#{content}"
        end
      end
      res = yield
      @__markus_buffer << res if String === res
      if self.class.__markus_indent
        @__markus_buffer << "#{"  " * @__markus_level}</#{tname}>"
      else
        @__markus_buffer << "</#{tname}>"
      end  
      @__markus_level -= 1
    else
      if @__markus_mode == :xml && content.nil?
        if self.class.__markus_indent
          @__markus_buffer << "#{"  " * (@__markus_level+1)}<#{tname}#{attrs}/>"
        else
          @__markus_buffer << "<#{tname}#{attrs}/>"
        end
      else
        if self.class.__markus_indent
          @__markus_buffer << "#{"  " * (@__markus_level+1)}<#{tname}#{attrs}>#{content}</#{tname}>" 
        else
          @__markus_buffer << "<#{tname}#{attrs}>#{content}</#{tname}>" 
        end
      end  
    end  
  end #}}}
  def __markus_json(tname,*args,&blk) #{{{ # :nodoc:
    attrs = nil
    content = "null"
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
          attrs = nil if attrs == "[  ]"
        when Hash
          attrs = "{ " + a.collect { |key,value|
            case value
              when Integer, Float
                value.nil? ? nil : "\"#{key}\": #{value}"
              else
                value.nil? ? nil : "\"#{key}\": \"#{value.to_s.gsub(/"/,'\\\"')}\""
            end
          }.compact.join(", ").strip + " }"
          attrs = nil if attrs == "{  }"
        when String
          content = "\"#{a.gsub(/"/,'\\\"')}\""
        when Integer, Float
          content = a
        else
          content = "\"#{a.to_s}\""
      end  
    end
    if blk
      @__markus_level += 1
      mpsic = @__markus_parent
      if mpsic == :a
        @__markus_parent = nil
        if self.class.__markus_indent
          @__markus_buffer << "#{"  " * @__markus_level}{"
        else  
          @__markus_buffer << "{"
        end
        __markus_json tname, *args, &blk
        @__markus_buffer.last.chop!
        if self.class.__markus_indent
          @__markus_buffer << "#{"  " * @__markus_level}},"
        else  
          @__markus_buffer << "},"
        end
      else 
        @__markus_parent = type = blk.parameters.length == 1 && blk.parameters[0][1] == :array ? :a : :h
        if self.class.__markus_indent
          @__markus_buffer << "#{"  " * @__markus_level}#{tname.nil? ? '' : "\"#{tname}\": "}#{type == :a ? '[' : '{'}"
        else  
          @__markus_buffer << "#{tname.nil? ? '' : "\"#{tname}\": "}#{type == :a ? '[' : '{'}"
        end
        res = blk.call
        @__markus_buffer << res + ',' if type == :a && res.is_a?(String)
        @__markus_buffer.last.chop!
        if self.class.__markus_indent
          @__markus_buffer << "#{"  " * @__markus_level}#{type == :a ? ']' : '}'},"
        else
          @__markus_buffer << "#{type == :a ? ']' : '}'},"
        end  
      end
      @__markus_level -= 1
      @__markus_parent = mpsic
    else
      if self.class.__markus_indent
        @__markus_buffer << "#{"  " * (@__markus_level+1)}\"#{tname}\": #{attrs || content}," 
      else
        @__markus_buffer << "\"#{tname}\": #{attrs || content}," 
      end
    end  
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
      self.__markus_indent           = false
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
    self.__markus_indent = true
  end #}}}

    def self::templates(some)
      self.__markus_includes << some
      self.__markus_templates.merge! some.__markus_templates
    end
end
