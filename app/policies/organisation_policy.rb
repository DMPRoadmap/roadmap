class OrganisationPolicy
  attr_reader :user, :organisation

  def initialize(user, organisation)
    @user = user
    @organisation = organisation
  end

  def admin_show?
    user.can_modify_org_details?
  end

  def admin_edit?
    user.can_modify_org_details?
  end

  def admin_update?
    user.can_modify_org_details?
  end

end