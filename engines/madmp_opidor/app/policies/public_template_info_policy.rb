# frozen_string_literal: true

# Security rules for templates
# This policy is used by the TemplatesController in the MadmpOpidor Engine
class PublicTemplateInfoPolicy < ApplicationPolicy
  def show?
    @user.present?
  end
end
