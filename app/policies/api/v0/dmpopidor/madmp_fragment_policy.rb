module Api
  module V0
    module Dmpopidor
      class MadmpFragmentPolicy < ApplicationPolicy
        attr_reader :user
        attr_reader :madmp_fragment

        def initialize(user, madmp_fragment)
          raise Pundit::NotAuthorizedError, _("must be logged in") unless user
          @user     = user
          @fragment = madmp_fragment
        end

        def show?
          plan = @fragment.plan
          plan.readable_by?(@user.id)
        end
      end 
    end
  end
end
