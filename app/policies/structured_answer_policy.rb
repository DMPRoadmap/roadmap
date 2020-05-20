class StructuredAnswerPolicy < ApplicationPolicy
  def initialize(user, fragment)
    raise Pundit::NotAuthorizedError, _("must be logged in") unless user
    @user = user
    @fragment = fragment
  end
  def create_or_update?
    @fragment.plan.editable_by?(@user.id) || @user == @answer.plan.owner
  end
  def destroy?
    @fragment.plan.editable_by?(@user.id) || @user == @answer.plan.owner
  end
  def get_fragment?
    @fragment.plan.editable_by?(@user.id) || @user == @answer.plan.owner
  end
end
