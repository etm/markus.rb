require '../MarkUS'

class MyClass < MarkUS
  markus_indent_!
  markus_xml_!

  def doit(items=[])
    html_ do
      head_ 'Hallo'
      body_ do
        do_something
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
