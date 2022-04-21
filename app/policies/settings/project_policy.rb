# frozen_string_literal: true

module Settings
  # Security rules project export settings
  class ProjectPolicy < ApplicationPolicy
    # this is the policy for app/controllers/settings/projects_controller.rb
    # for this controller, we allow all actions as the "settings" object
    # is curated by rails based on user, not on a passed param
    def show?
      true
    end

    def update?
      true
    end
  end
end
