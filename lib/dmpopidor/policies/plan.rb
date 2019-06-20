module Dmpopidor
  module Policies
    module Plan
      def research_outputs?
        @plan.readable_by?(@user.id)
      end
    end 
  end
end