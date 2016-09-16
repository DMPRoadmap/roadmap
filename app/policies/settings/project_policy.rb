class Settings::ProjectPolicy < ApplicationPolicy
  # this is the policy for app/controllers/settings/projects_controller.rb

  attr_reader :user
  attr_reader :projects

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

end