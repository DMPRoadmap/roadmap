# frozen_string_literal: true

# Security rules for madmpfragments
class MadmpFragmentPolicy < ApplicationPolicy
  def show?
    @record.plan.readable_by?(@user.id) || @user == @record.plan.owner
  end

  def create_json?
    @record.plan.editable_by?(@user.id) || @user == @record.plan.owner
  end

  def update_json?
    @record.plan.editable_by?(@user.id) || @user == @record.plan.owner
  end

  def create?
    @record.plan.readable_by?(@user.id) || @user == @record.plan.owner
  end

  def update?
    @record.plan.editable_by?(@user.id) || @user == @record.plan.owner
  end

  def load_form?
    @record.plan.readable_by?(@user.id) || @user == @record.plan.owner
  end

  def change_form?
    @record.plan.editable_by?(@user.id) || @user == @record.plan.owner
  end

  def destroy?
    @record.plan.editable_by?(@user.id) || @user == @record.plan.owner
  end

  def new_edit_linked?
    @record.plan.editable_by?(@user.id) || @user == @record.plan.owner
  end

  def show_linked?
    @record.plan.readable_by?(@user.id) || @user == @record.plan.owner
  end

  def create_from_registry_value?
    @record.plan.editable_by?(@user.id) || @user == @record.plan.owner
  end

  def create_contributor?
    @record.plan.editable_by?(@user.id) || @user == @record.plan.owner
  end

  def destroy_contributor?
    @record.plan.editable_by?(@user.id) || @user == @answer.plan.owner
  end

  def load_fragments?
    @record.plan.readable_by?(@user.id) || @user == @record.plan.owner
  end

  def run?
    @record.plan.editable_by?(@user.id) || @user == @record.plan.owner
  end

  def anr_search?
    @record.plan.editable_by?(@user.id) || @user == @record.plan.owner
  end
end
