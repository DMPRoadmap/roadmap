class SectionPolicy < ApplicationPolicy
  attr_reader :user, :section

  def initialize(user, section)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @section = section
  end

  ##
  # Users can modify sections if:
  #  - They can modify templates
  #  - The template which they are modifying belongs to their org
  ##

  def admin_create?
    user.can_modify_templates?  &&  (section.phase.template.org_id == user.org_id)
  end

  def admin_update?
puts "POLICY: #{user.inspect}"
puts "PERMS: #{user.perms.inspect}" unless user.nil?
    user.can_modify_templates?  &&  (section.phase.template.org_id == user.org_id)
  end

  def admin_destroy?
    user.can_modify_templates?  &&  (section.phase.template.org_id == user.org_id)
  end

end