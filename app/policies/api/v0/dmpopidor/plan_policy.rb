module Api
  module V0
    module Dmpopidor
      class PlanPolicy < ApplicationPolicy
        attr_reader :user
        attr_reader :plan

        def initialize(user, plan)
          raise Pundit::NotAuthorizedError, _("must be logged in") unless user
          @user     = user
          @plan = plan
        end

        def show?
          @plan.readable_by?(@user.id)
        end
      end 
    end
  end
end
