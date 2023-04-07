# frozen_string_literal: true

# Security rules for templates
# Note the method names here correspond with controller actions
class TemplatePolicy < ApplicationPolicy
  # NOTE: @user is the signed_in_user and @record is an instance of Template

  def index?
    @user.can_super_admin?
  end

  def preferences?
    @user.can_modify_templates?
  end

  def repository_search?
    @user.can_modify_templates?
  end

  def metadata_standard_search?
    @user.can_modify_templates?
  end

  def define_custom_repository?
    @user.can_modify_templates?
  end

  def organisational?
    @user.can_modify_templates?
  end

  def customisable?
    @user.can_modify_templates?
  end

  def new?
    @user.can_super_admin? || @user.can_modify_templates?
  end

  def create?
    @user.can_super_admin? || @user.can_modify_templates?
  end

  def show?
    @user.can_super_admin? || (@user.can_modify_templates? && @record.org_id == @user.org_id)
  end

  def edit?
    @user.can_super_admin? || (@user.can_modify_templates? && @record.org_id == @user.org_id)
  end

  def update?
    @user.can_super_admin? || (@user.can_modify_templates? && @record.org_id == @user.org_id)
  end

  def destroy?
    @user.can_super_admin? || (@user.can_modify_templates? && (@record.org_id == @user.org_id))
  end

  def history?
    @user.can_super_admin? || (@user.can_modify_templates? && @record.org_id == @user.org_id)
  end

  def customize?
    @user.can_super_admin? || @user.can_modify_templates?
  end

  def transfer_customization?
    @user.can_super_admin? || @user.can_modify_templates?
  end

  def template_export?
    @user.can_super_admin? || (@user.can_modify_templates? && (@record.org_id == @user.org_id))
  end

  def save_preferences?
    @user.can_modify_templates?
  end

  # AJAX Calls
  def copy?
    @user.can_super_admin? || (@user.can_modify_templates?  &&  (@record.org_id == @user.org_id))
  end

  def publish?
    @user.can_super_admin? || (@user.can_modify_templates?  &&  (@record.org_id == @user.org_id))
  end

  def unpublish?
    @user.can_super_admin? || (@user.can_modify_templates?  &&  (@record.org_id == @user.org_id))
  end

  ##
  # Users can modify templates if:
  #  - They can modify templates
  #  - The template which they are modifying belongs to their org
  ##

  # Anyone with an account should be able to get templates for the sepecified research_org + funder
  # This policy is applicable to the Create Plan page
  def template_options?
    @user.present?
  end

  # DMPTool customizations to allow Org Admins to create a plan from one of their
  # templates on behalf of a user
  def email?
    @user.can_super_admin? || (@user.can_modify_templates? && @record.org_id == @user.org_id)
  end

  def invite?
    @user.can_super_admin? || (@user.can_modify_templates? && @record.org_id == @user.org_id)
  end
end
