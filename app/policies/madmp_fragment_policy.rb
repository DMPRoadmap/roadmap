# frozen_string_literal: true

# Security rules for madmpfragments
class MadmpFragmentPolicy < ApplicationPolicy
  def create?
    @fragment.plan.readable_by?(@user.id) || @user == @answer.plan.owner
  end

  def update?
    @fragment.plan.editable_by?(@user.id) || @user == @answer.plan.owner
  end

  def load_form?
    @fragment.plan.readable_by?(@user.id) || @user == @answer.plan.owner
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
    @fragment.plan.editable_by?(@user.id) || @user == @answer.plan.owner
  end

  def create_contributor?
    @fragment.plan.editable_by?(@user.id) || @user == @answer.plan.owner
  end

  def destroy_contributor?
    @fragment.plan.editable_by?(@user.id) || @user == @answer.plan.owner
  end

  def load_fragments?
    @fragment.plan.readable_by?(@user.id) || @user == @answer.plan.owner
  end

  def run?
    @fragment.plan.editable_by?(@user.id) || @user == @answer.plan.owner
  end

  def anr_search?
    @fragment.plan.editable_by?(@user.id) || @user == @answer.plan.owner
  end
end
