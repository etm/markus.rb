require File.expand_path(File.dirname(__FILE__) + '/../lib/markus')

class MyClass < MarkUS
  indent

  template :main do
    query_ do
      match_all_ {}
    end
    query_ do
      match_ "NONE" => "NONE"
    end
  end
end

a = MyClass.new
puts a.json_! :main
