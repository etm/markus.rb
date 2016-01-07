# Markup UnderScore
# ----   -    -

class MarkUS
  @@__markus_reload = false
  @@__markus_reload_timestamp = nil
  @@__markus_file = nil
  @@__markus_indent = false

  def __markus_reload  #{{{
    if @@__markus_reload && @@__markus_reload_timestamp
      if File.stat(@@__markus_file).mtime > @@__markus_reload_timestamp
        load @@__markus_file
      end
    end
  end #}}}

  def json!(name) #{{{
    markus! name, :json
  end #}}}
  def xml!(name) #{{{
    markus! name, :xml
  end #}}}

  def markus!(name,type) #{{{
    @__markus = []
    @__markus_buffer = []
    @__markus_level = 0
    @__markus_parent = nil

    __markus_reload
    @__markus_mode = type

    template_!(name)
    @__markus_buffer.last.chop!
    @@__markus_indent ? @__markus_buffer.join("\n") : @__markus_buffer.join
  end
 #}}}
  def element_!(name, *args, &b) #{{{
    __markus name, *args, &b
  end #}}}
  def template_!(name) #{{{
    instance_eval &@@__markus_templates[name]
  end #}}}

  def method_missing(name,*args, &b) #{{{
    if name.to_s =~ /(.*)(__)$/ || name.to_s =~ /(.*)(_)$/
      __markus $1, *args, &b
    else
      p name
      super
    end  
  end #}}}
  def __markus(name,*args, &b) #{{{
    if @__markus_mode == :json
      __markus_json name, *args, &b
    else
      __markus_xml name, *args, &b
    end
  end #}}}
  def __markus_xml(tname,*args) #{{{
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
      if @@__markus_indent
        @__markus_buffer << "#{"  " * @__markus_level}<#{tname}#{attrs}>"
      else  
        @__markus_buffer << "<#{tname}#{attrs}>"
      end  
      unless content.nil?
        if @@__markus_indent
          @__markus_buffer << "#{"  " * (@__markus_level+1)}#{content}"
        else
          @__markus_buffer << "#{content}"
        end
      end
      res = yield
      @__markus_buffer << res if String === res
      if @@__markus_indent
        @__markus_buffer << "#{"  " * @__markus_level}</#{tname}>"
      else
        @__markus_buffer << "</#{tname}>"
      end  
      @__markus_level -= 1
    else
      if @__markus_xml && content.nil?
        if @@__markus_indent
          @__markus_buffer << "#{"  " * (@__markus_level+1)}<#{tname}#{attrs}/>"
        else
          @__markus_buffer << "<#{tname}#{attrs}/>"
        end
      else
        if @@__markus_indent
          @__markus_buffer << "#{"  " * (@__markus_level+1)}<#{tname}#{attrs}>#{content}</#{tname}>" 
        else
          @__markus_buffer << "<#{tname}#{attrs}>#{content}</#{tname}>" 
        end
      end  
    end  
  end #}}}
  def __markus_json(tname,*args,&bl) #{{{
    attrs = nil
    content = "null"
    args.each do |a|
      case a
        when Array
          attrs << "[ " + a.collect { |key,value|
            case value
              when Integer, Float
                value.nil? ? nil : "#{value}"
              else
                value.nil? ? nil : "\"#{value.to_s.gsub(/"/,'\\\"')}\""
            end
          }.compact.join(", ").strip + " ]"
          attrs = nil if attrs == "[  ]"
        when Hash
          attrs << "{ " + a.collect { |key,value|
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
      end  
    end
    if bl
      @__markus_level += 1
      mpsic = @__markus_parent
      if mpsic == :a
        @__markus_parent = nil
        if @@__markus_indent
          @__markus_buffer << "#{"  " * @__markus_level}{"
        else  
          @__markus_buffer << "{"
        end
        __markus_json tname, *args, &bl
        @__markus_buffer.last.chop!
        if @@__markus_indent
          @__markus_buffer << "#{"  " * @__markus_level}},"
        else  
          @__markus_buffer << "},"
        end
      else 
        @__markus_parent = type = bl.parameters.length == 1 && bl.parameters[0][1] == :array ? :a : :h
        if @@__markus_indent
          @__markus_buffer << "#{"  " * @__markus_level}#{tname.nil? ? '' : "\"#{tname}\": "}#{type == :a ? '[' : '{'}"
        else  
          @__markus_buffer << "#{tname.nil? ? '' : "\"#{tname}\": "}#{type == :a ? '[' : '{'}"
        end
        res = bl.call
        @__markus_buffer << res + ',' if type == :a && res.is_a?(String)
        @__markus_buffer.last.chop!
        if @@__markus_indent
          @__markus_buffer << "#{"  " * @__markus_level}#{type == :a ? ']' : '}'},"
        else
          @__markus_buffer << "#{type == :a ? ']' : '}'},"
        end  
      end
      @__markus_level -= 1
      @__markus_parent = mpsic
    else
      if @@__markus_indent
        @__markus_buffer << "#{"  " * (@__markus_level+1)}\"#{tname}\": #{attrs || content}," 
      else
        @__markus_buffer << "\"#{tname}\": #{attrs || content}," 
      end
    end  
  end #}}}

  def self::inherited(subclass) #{{{
    subclass.instance_eval do
      # This array contains strings like "/path/to/a.rb:3:in `instance_eval'".
      strings_ary = caller

      # We look for the last string containing "<top (required)>".
      # only works in > 1.9
      require_index = strings_ary.rindex {|x| x.include?("<top (required)>") }
      require_string = strings_ary[require_index]

      # We use a regex to extract the filepath from require_string.
      filepath = require_string[/^(.*):\d+:in `<top \(required\)>'/, 1]

      # This defines the method #get_file for instances of `subclass`.
      @@__markus_file = filepath
    end
  end #}}}

  def self::reload #{{{
    @@__markus_reload = true
    @@__markus_reload_timestamp = File.stat(@@__markus_file).mtime
  end #}}}
  def self::template(name,&p) #{{{
    @@__markus_templates ||= {}
    @@__markus_templates[name] = p
  end #}}}
  def self::indent #{{{
    @@__markus_indent = true
  end #}}}
end
