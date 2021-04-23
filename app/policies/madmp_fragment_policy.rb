class MadmpFragmentPolicy < ApplicationPolicy
  def initialize(user, fragment)
    raise Pundit::NotAuthorizedError, _("must be logged in") unless user
    @user = user
    @fragment = fragment
  end

  def create?
    @fragment.plan.editable_by?(@user.id) || @user == @answer.plan.owner
  end

  def update?
    @fragment.plan.editable_by?(@user.id) || @user == @answer.plan.owner
  end

  def load_form?
    @fragment.plan.editable_by?(@user.id) || @user == @answer.plan.owner
  end

  def change_schema?
    @fragment.plan.editable_by?(@user.id) || @user == @answer.plan.owner
  end

  def destroy?
    @fragment.plan.editable_by?(@user.id) || @user == @answer.plan.owner
  end

  def new_edit_linked?
    @fragment.plan.editable_by?(@user.id) || @user == @answer.plan.owner
  end

  def show_linked?
    @fragment.plan.readable_by?(@user.id) || @user == @answer.plan.owner
  end

  def create_from_registry_value?
    @fragment.plan.readable_by?(@user.id) || @user == @answer.plan.owner
  end

  def create_contributor?
    @fragment.plan.readable_by?(@user.id) || @user == @answer.plan.owner
  end

  def run?
    @fragment.plan.editable_by?(@user.id) || @user == @answer.plan.owner
  end

end
