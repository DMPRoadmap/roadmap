# frozen_string_literal: true
<<<<<<< HEAD

class SectionPolicy < ApplicationPolicy

  attr_reader :user, :section

  def initialize(user, section)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user

    @user = user
    @section = section
  end
=======

# Security rules for template sections
# Note the method names here correspond with controller actions
class SectionPolicy < ApplicationPolicy
  # NOTE: @user is the signed_in_user and @record is an instance of Section
>>>>>>> upstream/master

  ##
  # Users can modify sections if:
  #  - They can modify templates
  #  - The template which they are modifying belongs to their org
  ##
  def index?
    @user.present?
  end

<<<<<<< HEAD
  def index?
    user.present?
  end

  def show?
    user.present?
  end

  def edit?
    user.can_modify_templates?  &&  (section.phase.template.org_id == user.org_id)
  end

  def new?
    user.can_modify_templates?  &&  (section.phase.template.org_id == user.org_id)
  end

  def create?
    user.can_modify_templates?  &&  (section.phase.template.org_id == user.org_id)
  end

  def update?
    user.can_modify_templates?  &&  (section.phase.template.org_id == user.org_id)
  end

  def destroy?
    user.can_modify_templates?  &&  (section.phase.template.org_id == user.org_id)
  end

=======
  def show?
    @user.present?
  end

  def edit?
    @user.can_modify_templates?  &&  (@record.phase.template.org_id == @user.org_id)
  end

  def new?
    @user.can_modify_templates?  &&  (@record.phase.template.org_id == @user.org_id)
  end

  def create?
    @user.can_modify_templates?  &&  (@record.phase.template.org_id == @user.org_id)
  end

  def update?
    @user.can_modify_templates?  &&  (@record.phase.template.org_id == @user.org_id)
  end

  def destroy?
    @user.can_modify_templates?  &&  (@record.phase.template.org_id == @user.org_id)
  end
>>>>>>> upstream/master
end
