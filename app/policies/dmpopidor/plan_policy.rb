# frozen_string_literal: true

module Dmpopidor
  # Security rules for plan tables
  module PlanPolicy
    def classic_edit?
      @record.readable_by?(@user.id)
    end

    def structured_edit?
      @record.readable_by?(@user.id)
    end

    def research_outputs?
      @record.readable_by?(@user.id)
    end

    def budget?
      @record.readable_by?(@user.id)
    end

    def guidance_groups?
      @record.editable_by?(@user.id)
    end

    def select_guidance_groups?
      @record.editable_by?(@user.id)
    end

    def question_guidances?
      @record.readable_by?(@user.id)
    end

    def create_remote?
      @record.editable_by?(@user.id)
    end

    def update_remote?
      @record.editable_by?(@user.id)
    end

    def destroy_remote?
      @record.editable_by?(@user.id)
    end

    def sort?
      @record.editable_by?(@user.id)
    end

    def load_values?
      @record.readable_by?(@user.id)
    end

    def import?
      @user.present?
    end

    def import_plan?
      @user.present?
    end

    def answers_data?
      @record.readable_by?(@user.id)
    end

    def contributors_data?
      @record.readable_by?(@user.id)
    end
  end
end
