module Dmpopidor
  module Model
    module Plan
      # Deactivates the plan (sets all roles to inactive and visibility to :private)
      #
      # Returns Boolean
      def deactivate!
        # If no other :creator, :administrator or :editor is attached
        # to the plan, then also deactivate all other active roles
        # and set the plan's visibility to :private
        # CHANGE : visibility setting to privately_private_visible
        if authors.size == 0
          roles.where(active: true).update_all(active: false)
          self.visibility = Plan.visibilities[:privately_private_visible]
          save!
        else
          false
        end
      end
    end
  end
end