# frozen_string_literal: true

module Paginable
<<<<<<< HEAD

  class PlanPolicy < ApplicationPolicy

    def initialize(user)
      @user = user
    end
=======
  # Security rules for plan tables
  class PlanPolicy < ApplicationPolicy
    # NOTE: @user is the signed_in_user
>>>>>>> upstream/master

    def privately_visible?
      @user.is_a?(User)
    end

    def organisationally_or_publicly_visible?
      @user.is_a?(User)
    end
<<<<<<< HEAD

  end

=======
  end
>>>>>>> upstream/master
end
