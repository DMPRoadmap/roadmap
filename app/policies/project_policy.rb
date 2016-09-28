class ProjectPolicy < ApplicationPolicy
  attr_reader :user
  attr_reader :project

  def initialize(user, project)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @project = project
  end

  def show?
    @project.readable_by(@user.id)
  end

  def edit?
    @project.editable_by(@user.id)
  end

  def share?
    @project.editable_by(@user.id)
  end

  def export?
    @project.readable_by(@user.id)
  end

  def update?
    @project.editable_by(@user.id)
  end

  def destroy?
    @project.editable_by(@user.id)
  end

  def possible_templates?
    true
  end

  def possible_guidance?
    true
  end
end