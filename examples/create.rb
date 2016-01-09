require File.expand_path(File.dirname(__FILE__) + '/../lib/markus')

class MyClass < MarkUS
  indent

  template :sub do
    input_ :name => 'something'
  end

  template :main do
    html_ do
      body_ :class => 'test' do
        template_! :sub
        1.upto 3 do
          a_ 'test', :href => 'https://github.com/etm'
        end  
      end
    end
  end

  private  
    def do_something
      "hello world"
    end
end

a = MyClass.new
puts a.html_! :main
