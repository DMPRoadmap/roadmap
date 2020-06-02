module Dmpopidor
  module Policies
    module Paginable
      module Plan
        def administrator_visible?
          @user.is_a?(User)
        end
      end 
    end
  end
end