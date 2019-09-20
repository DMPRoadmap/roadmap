module Dmpopidor
    module Helpers
      module Exports

        # Changed label
        def plan_attribution(attribution)
          attribution = Array(attribution)
          prefix = attribution.many? ? d_("dmpopidor", "DMP Creators:") : d_("dmpopidor", "DMP Creator:")
          "<strong>#{prefix}</strong> #{attribution.join(', ')}"
        end

    end
  end
end