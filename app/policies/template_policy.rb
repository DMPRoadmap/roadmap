class TemplatePolicy < ApplicationPolicy
  attr_reader :user, :template
  
  def initialize(user, template = Template.new)
    raise Pundit::NotAuthorizedError, _("must be logged in") unless user.is_a?(User)
    @user = user
    @template = template
  end
  
  def index?
    user.can_super_admin?
  end

  def organisational?
    user.can_modify_templates?
  end
  
  def customisable?
    user.can_modify_templates?
  end
  
  def new?
    user.can_super_admin? || user.can_modify_templates?
  end

  def create?
    user.can_super_admin? || user.can_modify_templates?
  end

  def show?
    user.can_super_admin? || (user.can_modify_templates? && template.org_id == user.org_id)
  end
  
  def edit?
    user.can_super_admin? || (user.can_modify_templates? && template.org_id == user.org_id)
  end

  def update?
    user.can_super_admin? || (user.can_modify_templates? && template.org_id == user.org_id)
  end

  def destroy?
    user.can_super_admin? || (user.can_modify_templates?  &&  (template.org_id == user.org_id))
  end
  
  def history?
    user.can_super_admin? || (user.can_modify_templates? && template.org_id == user.org_id)
  end

  def customize?
    user.can_super_admin? || user.can_modify_templates?
  end

  def transfer_customization?
    user.can_super_admin? || user.can_modify_templates?
  end

  # AJAX Calls
  def copy?
    user.can_super_admin? || (user.can_modify_templates?  &&  (template.org_id == user.org_id))
  end
  def publish?
    user.can_super_admin? || (user.can_modify_templates?  &&  (template.org_id == user.org_id))
  end
  def unpublish?
    user.can_super_admin? || (user.can_modify_templates?  &&  (template.org_id == user.org_id))
  end


  ##
  # Users can modify templates if:
  #  - They can modify templates
  #  - The template which they are modifying belongs to their org
  ##



  # Anyone with an account should be able to get templates for the sepecified research_org + funder
  # This policy is applicable to the Create Plan page
  def template_options?
    user.present?
  end


end