# frozen_string_literal: true

class UsageController < ApplicationController

  # GET /usage
  def index
    unless current_user.present? &&
          (current_user.can_org_admin? || current_user.can_super_admin?)
      raise Pundit::NotAuthorizedError
    end
    render("index",
      locals: {
        orgs: Org.all,
        total_org_users: current_user.org.users.size,
        total_org_plans: current_user.org.plans.size
      }
    )
  end

end
