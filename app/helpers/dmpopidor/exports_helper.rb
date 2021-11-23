# frozen_string_literal: true

module Dmpopidor

  module ExportsHelper

    # Changed label
    def plan_attribution(attribution)
      attribution = Array(attribution)
      prefix = attribution.many? ? _("DMP Creators:") : _("DMP Creator:")
      "<strong>#{prefix}</strong> #{attribution.join(', ')}"
    end

  end

end
