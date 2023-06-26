# frozen_string_literal: true

# Security rules for registry
class Template < ApplicationPolicy
  def show?
    @user.present?
  end
end
