# frozen_string_literal: true
<<<<<<< HEAD

class PhasePolicy < ApplicationPolicy

  attr_reader :user, :phase

  def initialize(user, phase)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user

    @user = user
    @phase = phase
  end
=======

# Security rules for template phases
# Note the method names here correspond with controller actions
class PhasePolicy < ApplicationPolicy
  # NOTE: @user is the signed_in_user and @record is an instance of Phase
>>>>>>> upstream/master

  ##
  # Org-admin side
  # Users can modify phases if:
  #  - They can modify templates
  #  - The template which they are modifying belongs to their org

  def show?
<<<<<<< HEAD
    user.can_modify_templates?  && (phase.template.org_id == user.org_id)
  end

  def preview?
    user.can_modify_templates?  &&  (phase.template.org_id == user.org_id)
  end

  def update?
    user.can_modify_templates?  &&  (phase.template.org_id == user.org_id)
  end

  def new?
    user.can_modify_templates?  && (phase.template.org_id == user.org_id)
  end

  def create?
    user.can_modify_templates?  &&  (phase.template.org_id == user.org_id)
  end

  def destroy?
    user.can_modify_templates?  &&  (phase.template.org_id == user.org_id)
  end

  def sort?
    user.can_modify_templates?  &&  (phase.template.org_id == user.org_id)
  end

=======
    @user.can_modify_templates? && (@record.template.org_id == @user.org_id)
  end

  def preview?
    @user.can_modify_templates? && (@record.template.org_id == @user.org_id)
  end

  def edit?
    user.can_modify_templates? && (@record.template.org_id == user.org_id)
  end

  def update?
    @user.can_modify_templates? && (@record.template.org_id == @user.org_id)
  end

  def new?
    @user.can_modify_templates? && (@record.template.org_id == @user.org_id)
  end

  def create?
    @user.can_modify_templates? && (@record.template.org_id == @user.org_id)
  end

  def destroy?
    @user.can_modify_templates? && (@record.template.org_id == @user.org_id)
  end

  def sort?
    @user.can_modify_templates? && (@record.template.org_id == @user.org_id)
  end
>>>>>>> upstream/master
end
