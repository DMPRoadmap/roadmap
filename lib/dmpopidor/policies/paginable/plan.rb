module Dmpopidor
  module Policies
    module Paginable
      module Plan
        def privately_private_visible?
          @user.is_a?(User)
        end
      end 
    end
  end
end