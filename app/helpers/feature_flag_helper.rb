module FeatureFlagHelper
    def self.enabled?(feature)
        case feature.to_sym

        when :on_sandbox
            Rails.env.sandbox?
        else
            false
        end
    end
end