class TemplatePolicy < ApplicationPolicy
  attr_reader :user, :template

  def initialize(user, template)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @template = template
  end

  ##
  # Users can modify templates if:
  #  - They can modify templates
  #  - The template which they are modifying belongs to their org
  ##

  def admin_index?
    user.can_modify_templates?
  end

  def admin_template?
    user.can_modify_templates?  &&  (template.org_id == user.org_id)
  end

  def admin_update?
    user.can_modify_templates?  &&  (template.org_id == user.org_id)
  end

  def admin_new?
    user.can_modify_templates?
  end

  def admin_create?
    user.can_modify_templates? && (template.org_id.nil? || (template.org_id == user.org_id))
  end

  def admin_destroy?
    user.can_modify_templates?  &&  (template.org_id == user.org_id)
  end

  def admin_template_history?
    user.can_modify_templates? && (template.org_id == user.org_id)
  end


  class Scope < Scope
    def resolve
      scope.where(org_id: user.org_id)
    end
  end

end