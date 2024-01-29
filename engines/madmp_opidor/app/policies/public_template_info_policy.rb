# frozen_string_literal: true

# Security rules for templates
# This policy is used by the TemplatesController in the MadmpOpidor Engine
class PublicTemplateInfoPolicy < ApplicationPolicy
  def show?
    @user.present?
  end

  def set_recommended?
    @user.can_super_admin?
  end
end
