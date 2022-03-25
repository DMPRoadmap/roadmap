# frozen_string_literal: true

module Dmpopidor
  # Customized code for Template model
  module Template
    def structured?
      questions.where(madmp_schema_id: nil).empty?
    end
  end
end
