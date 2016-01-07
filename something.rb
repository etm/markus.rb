class Something < MarkUS
  reload
  indent

  def some
    template_! :common
  end

  template :common do
    from_ 1
    size_ 6
  end

  template :main do
    template_! :common
    some
    query_ do
      filtered_ do
        filter_ do
          bool_ do
            must_ do |array|
              bool_ do
                should_ do |array|
                  nested_ do
                    path_ "contact"
                    query_ do
                      term_ do
                        element_! "contact.durchwahl", 1
                      end
                    end
                  end

                  nested_ do
                    path_ "contact"
                    query_ do 
                      term_ do
                        element_! "contact.durchwahl", "aaa"
                      end
                    end
                  end
  
                end
              end
            end
          end       
        end
      end
    end    
  end
end
