# frozen_string_literal: true

module Dmpopidor
  # Customized code for Org model
  module Org
    def org_admin_plans
      combined_plan_ids = affiliated_plan_ids.flatten.uniq

      ::Plan.includes(:template, :phases, :roles, :users).where(id: combined_plan_ids)
            .where.not(visibility: ::Plan.visibilities[:privately_visible])
            .where.not(visibility: ::Plan.visibilities[:is_test])
            .where(roles: { active: true })
    end
  end
end
