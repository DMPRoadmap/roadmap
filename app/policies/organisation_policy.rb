class OrganisationPolicy < ApplicationPolicy
  attr_reader :user, :organisation

  def initialize(user, organisation)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @organisation = organisation
  end

  def admin_show?
    user.can_modify_org_details? && (user.organisation_id == organisation.id)
  end

  def admin_edit?
    user.can_modify_org_details? && (user.organisaiton_id == organisation.id)
  end

  def admin_update?
    user.can_modify_org_details? && (user.organisaiton_id == organisation.id)
  end

end