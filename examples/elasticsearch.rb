require File.expand_path(File.dirname(__FILE__) + '/../lib/markus')

class MyClass < MarkUS
  indent

  template :main do
    query_ do
      function_score_ do
        functions_ do |array|
        end
        function_score_ do
          functions_ do |array|
            boost_factor_ 1
            element_! do 
              gauss_ do
                semester_boost_ do
                  origin_ 14
                  scale_ 1
                end
              end
            end
          end
          query_ do
            indices_ do
              indices_ :a
              no_match_query_ "none"
            end
          end
        end
      end
    end
  end
end

a = MyClass.new
puts a.json_! :main
