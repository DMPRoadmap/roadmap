class AnnotationPolicy < ApplicationPolicy
  attr_reader :user, :annotation

  def initialize(user, annotation)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @annotation = annotation
  end

  ##
  # Users can modify annotations if:
  #  - They can modify templates
  #  - The template which they are modifying belongs to their orggi
  ##

  def admin_create?
    user.can_modify_templates?  &&  (annotation.question.section.phase.template.org_id == user.org_id)
  end

  def admin_update?
    user.can_modify_templates?  &&  (annotation.question.section.phase.template.org_id == user.org_id)
  end

  def admin_destroy?
    user.can_modify_templates?  &&  (annotation.question.section.phase.template.org_id == user.org_id)
  end

endgi