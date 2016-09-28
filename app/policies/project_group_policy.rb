class ProjectGroupPolicy < ApplicationPolicy
  attr_reader :user
  attr_reader :project_group

  def initialize(user, project_group)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @project_group = project_group
  end

  def create?
    @project_group.project.administerable_by(@user.id)
  end

  def update?
    @project_group.project.administerable_by(@user.id)
  end

  def destroy?
    @project_group.project.administerable_by(@user.id)
  end
end