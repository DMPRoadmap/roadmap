# frozen_string_literal: true

module Settings
  # Security rules plan export settings
  class PlanPolicy < ApplicationPolicy
    # NOTE: @user is the signed_in_user and @record is an instance of Plan

    def show?
      @record.readable_by(@user.id)
    end

    def update?
      @record.editable_by(@user.id)
    end
  end
end
