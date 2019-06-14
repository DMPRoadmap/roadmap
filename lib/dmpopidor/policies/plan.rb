module Dmpopidor
  module Policies
    module Plan
      def datasets?
        @plan.readable_by?(@user.id)
      end
    end 
  end
end