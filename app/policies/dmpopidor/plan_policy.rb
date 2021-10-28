# frozen_string_literal: true

module Dmpopidor

  module PlanPolicy

    def research_outputs?
      @plan.readable_by?(@user.id)
    end

    def budget?
      @plan.readable_by?(@user.id)
    end

  end

end
