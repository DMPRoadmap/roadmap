class PublicPagePolicy < ApplicationPolicy

  def initialize( object)
    # no requirement for users to be signed in here
    @object = object
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

end
