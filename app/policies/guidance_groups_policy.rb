class GuidanceGroupsPolicy
  attr_reader :user, :guidance

  def initialize(user, guidance)
    @user = user
    @guidance = guidance
  end

  def admin_show?
    user.can_modify_guidance?
  end

  def admin_edit?
    user.can_modify_guidance?
  end

  def admin_update?
    user.can_modify_guidance?
  end

  def admin_update_publish?
    user.can_modify_guidance?
  end

  def admin_new?
    user.can_modify_guidance?
  end

  def admin_create?
    user.can_modify_guidance?
  end

  def admin_destroy?
    user.can_modify_guidance?
  end

end