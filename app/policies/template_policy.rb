class TemplatePolicy < ApplicationPolicy
  attr_reader :user, :template

  def initialize(user, template)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @template = template
  end

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
    user.can_modify_templates?  &&  (template.org_id == user.org_id)
  end

  def admin_destroy?
    user.can_modify_templates?  &&  (template.org_id == user.org_id)
  end

  def admin_phase?
    user.can_modify_templates?  &&  (template.org_id == user.org_id)
  end

  def admin_previewphase?
    user.can_modify_templates?  &&  (template.org_id == user.org_id)
  end

  def admin_addphase?
    user.can_modify_templates?  &&  (template.org_id == user.org_id)
  end

  def admin_createphase?
    user.can_modify_templates?  &&  (template.org_id == user.org_id)
  end

  def admin_updatephase?
    user.can_modify_templates?  &&  (template.org_id == user.org_id)
  end

  def admin_destroyphase?
    user.can_modify_templates?  &&  (template.org_id == user.org_id)
  end

  def admin_updateversion?
    user.can_modify_templates?  &&  (template.org_id == user.org_id)
  end

  def admin_cloneversion?
    user.can_modify_templates?  &&  (template.org_id == user.org_id)
  end

  def admin_destroyversion?
    user.can_modify_templates?  &&  (template.org_id == user.org_id)
  end

  def admin_createsection?
    user.can_modify_templates?  &&  (template.org_id == user.org_id)
  end

  def admin_updatesection?
    user.can_modify_templates?  &&  (template.org_id == user.org_id)
  end

  def admin_destroysection?
    user.can_modify_templates?  &&  (template.org_id == user.org_id)
  end

  def admin_createquestion?
    user.can_modify_templates?  &&  (template.org_id == user.org_id)
  end

  def admin_updatequestion?
    user.can_modify_templates?  &&  (template.org_id == user.org_id)
  end

  def admin_destroyquestion?
    user.can_modify_templates?  &&  (template.org_id == user.org_id)
  end

  def admin_createsuggestedanswer?
    user.can_modify_templates?  &&  (template.org_id == user.org_id)
  end

  def admin_updatesuggestedanswer?
    user.can_modify_templates?  &&  (template.org_id == user.org_id)
  end

  def admin_destroysuggestedanswer?
    user.can_modify_templates?  &&  (template.org_id == user.org_id)
  end

  def admin_createguidance?
    user.can_modify_templates?  &&  (template.org_id == user.org_id)
  end

  def admin_updateguidance?
    user.can_modify_templates?  &&  (template.org_id == user.org_id)
  end

  def admin_destroyguidance?
    user.can_modify_templates?  &&  (template.org_id == user.org_id)
  end

  class Scope < Scope
    def resolve
      scope.where(org_id: user.org_id)
    end
  end

end