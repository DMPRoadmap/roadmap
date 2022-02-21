# frozen_string_literal: true

module Api
  module V0
    # Security rules for API V0 Theme endpoints
    class ThemePolicy < ApplicationPolicy
      attr_reader :user, :theme

      ##
      # always allowed as index chooses which themes to display
      def extract?
        true
      end
    end
  end
end
