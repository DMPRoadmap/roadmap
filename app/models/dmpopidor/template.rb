# frozen_string_literal: true

module Dmpopidor
  # Customized code for Template model
  module Template
    def structured?
      type.eql?('structured')
    end
  end
end
