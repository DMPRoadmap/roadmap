# frozen_string_literal: true

module Paginable
  # Security rules for plan tables
  class PlanPolicy < ApplicationPolicy
    # --------------------------------
    # Start DMP OPIDoR Customization
    # --------------------------------
    prepend Dmpopidor::Paginable::PlanPolicy
    # --------------------------------
    # Start DMP OPIDoR Customization
    # CHANGES : changed firstname & lastname, deleted user_identifiers & added some log
    # --------------------------------

    # NOTE: @user is the signed_in_user

    def privately_visible?
      @user.is_a?(User)
    end

    def organisationally_or_publicly_visible?
      @user.is_a?(User)
    end
  end
end
