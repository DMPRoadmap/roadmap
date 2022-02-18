# frozen_string_literal: true

module Dmpopidor
  # Security rules for plan tables
  module PlanPolicy
    def research_outputs?
      @plan.readable_by?(@user.id)
    end

    def budget?
      @plan.readable_by?(@user.id)
    end
  end
end
