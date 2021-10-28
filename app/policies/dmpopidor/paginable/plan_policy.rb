# frozen_string_literal: true

module Dmpopidor

  module Paginable

    module PlanPolicy

      def administrator_visible?
        @user.is_a?(User)
      end

    end

  end
end
