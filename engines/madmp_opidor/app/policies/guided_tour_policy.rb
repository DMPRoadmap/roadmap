# frozen_string_literal: true

# Security rules for guided tour
class GuidedTourPolicy < ApplicationPolicy
  def get_tour?
    @user.present?
  end

  def end_tour?
    @user.present?
  end
end
