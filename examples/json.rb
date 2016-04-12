require File.expand_path(File.dirname(__FILE__) + '/../lib/markus')

class MyClass < MarkUS
  indent

  template :main do
    query_ do
      match_all_ {}
    end
    query_ do
      match_ "NONE" => "NONE"
      functions_ do |array|
        element_! do
          weight_ 1
          filter_ do
            bool_ do
              must_ do |array|
                term_ do
                  element_! "groups.ww.day",  'a'
                end
                range_ do
                  element_! "groups.ww.tfrom" do
                    gte_ 'b'
                  end
                end
                range_ do
                  element_! "groups.ww.tto" do
                    lte_ 'c'
                  end
                end
              end
            end
          end
        end
        element_! do
          weight_ 0
        end
        value_! 12
      end
    end
  end
end

a = MyClass.new
puts a.json_! :main
