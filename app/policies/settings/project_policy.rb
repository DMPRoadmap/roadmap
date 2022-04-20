# frozen_string_literal: true
<<<<<<< HEAD

class Settings::ProjectPolicy < ApplicationPolicy

  # this is the policy for app/controllers/settings/projects_controller.rb
=======
>>>>>>> upstream/master

module Settings
  # Security rules project export settings
  class ProjectPolicy < ApplicationPolicy
    # this is the policy for app/controllers/settings/projects_controller.rb
    # for this controller, we allow all actions as the "settings" object
    # is curated by rails based on user, not on a passed param
    def show?
      true
    end

<<<<<<< HEAD
  def initialize(user, settings)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user

    @user = user
    @settings = settings
  end

  # for this controller, we allow all actions as the "settings" object
  # is curated by rails based on user, not on a passed param

  def show?
    true
  end

  def update?
    true
  end

=======
    def update?
      true
    end
  end
>>>>>>> upstream/master
end
