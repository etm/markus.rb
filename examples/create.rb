require '../MarkUS'

class MyClass < MarkUS
  markus_indent_!
  markus_xml_!

  def doit(items=[])
    html_ do
      body_ :class => 'test' do
        ...
      end
    end
  end

  private  
    def do_something
      a__      
    end
end

a = MyClass.new
puts a.doit
