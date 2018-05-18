class PublicPagePolicy < ApplicationPolicy

  def initialize(object, object2 = nil)
    @object = object
    @object2 = object2
  end

  def plan_index?
    true
  end

  def template_index?
    true
  end

  def template_export?
    @object.is_default || @object.org.funder?
  end

  def plan_export?
    @object.publicly_visible?
  end

  def plan_organisationally_exportable?
    plan = @object
    user = @object2
    if plan.is_a?(Plan) && user.is_a?(User)
      return plan.publicly_visible? || (plan.organisationally_visible? && plan.owner.present? && plan.owner.org_id == user.org_id)
    end
    return false;
  end
end
